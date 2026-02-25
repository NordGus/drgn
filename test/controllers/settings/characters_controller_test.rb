require "test_helper"

class Settings::CharactersControllerTest < ActionDispatch::IntegrationTest
  setup { @character = characters(:luffy) }

  class WithAnAuthenticatedCharacter < self
    setup { sign_in_as @character }
    teardown { sign_out }

    test "should show character" do
      get settings_character_url
      assert_response :success
    end

    test "should update character when the current users password is passed" do
      assert_changes -> { @character.reload.tag } do
        assert_changes -> { @character.reload.contact_address } do
          assert_difference -> { @character.reload.sessions.count }, -1 do
            patch settings_character_url, params: { character: { tag: "monkey.d.luffy", contact_address: "yonko-luffy@mugiwara.com", confirmation_password: "password" } }
            assert_redirected_to settings_character_url
          end
        end
      end
    end

    test "should not update character when an invalid password is passed" do
      assert_no_changes -> { @character.reload.tag } do
        assert_no_changes -> { @character.reload.contact_address } do
          assert_no_difference -> { @character.reload.sessions.count } do
            patch settings_character_url, params: { character: { tag: "monkey.d.luffy", contact_address: "yonko-luffy@mugiwara.com", confirmation_password: "invalid_password" } }
            assert_response :unprocessable_entity
          end
        end
      end
    end

    test "should mark character as deleted" do
      assert_difference -> { Character.active.count }, -1 do
        assert_difference -> { Session.count }, -1 do
          delete settings_character_url, params: { character: { confirmation_password: "password" } }
          assert_redirected_to root_url

          assert_not_nil @character.reload.deleted_at
        end
      end
    end

    test "should not destroy character when an invalid password is passed" do
      assert_no_difference -> { Character.active.count } do
        delete settings_character_url, params: { character: { confirmation_password: "invalid_password" } }
        assert_response :unprocessable_entity
      end
    end
  end

  class WithAnUnauthenticatedCharacter < self
    test "should not show character" do
      get settings_character_url
      assert_redirected_to new_session_url
    end

    test "should not update character when the current users password is passed" do
      assert_no_changes -> { @character.reload.tag } do
        assert_no_changes -> { @character.reload.contact_address } do
          assert_no_difference -> { @character.reload.sessions.count } do
            patch settings_character_url, params: { character: { tag: "monkey-d-luffy", contact_address: "one@mugiwara.com", confirmation_password: "password" } }
            assert_redirected_to new_session_url
          end
        end
      end
    end

    test "should not destroy character" do
      assert_no_difference "Character.count" do
        delete settings_character_url
      end

      assert_redirected_to new_session_url
    end
  end
end
