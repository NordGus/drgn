require "test_helper"

class Settings::CharactersControllerTest < ActionDispatch::IntegrationTest
  include ActiveJob::TestHelper
  setup { @character = characters(:luffy) }

  class WithAnAuthenticatedCharacter < self
    setup { sign_in_as @character }
    teardown { sign_out }

    test "should show character" do
      get settings_character_url
      assert_response :success
    end

    test "should update character when the current users password is passed" do
      freeze_time do
        assert_changes -> { @character.reload.contact_address } do
          assert_changes -> { @character.reload.tag } do
            assert_difference -> { @character.reload.sessions.count }, -1 do
              assert_enqueued_with job: Character::OnUpdateJob, args: [ @character.reload, Time.current ] do
                patch settings_character_url, params: { character: { tag: "monkey.d.luffy", contact_address: "yonko-luffy@mugiwara.com", password: "password" } }
                assert_redirected_to settings_character_url
              end
            end
          end
        end
      end
    end

    test "should not update character when an invalid password is passed" do
      assert_no_changes -> { @character.reload.contact_address } do
        assert_no_changes -> { @character.reload.tag } do
          assert_no_difference -> { @character.reload.sessions.count } do
            assert_no_enqueued_jobs only: [ Character::OnUpdateJob ] do
              patch settings_character_url, params: { character: { tag: "monkey.d.luffy", contact_address: "yonko-luffy@mugiwara.com", password: "invalid_password" } }

              assert_response :unprocessable_entity
            end
          end
        end
      end
    end

    test "should destroy character" do
      assert_difference("Character.count", -1) do
        delete settings_character_url
      end

      assert_redirected_to root_url
    end
  end

  class WithAnUnauthenticatedCharacter < self
    test "should not show character" do
      get settings_character_url
      assert_redirected_to new_session_url
    end

    test "should not update character when the current users password is passed" do
      assert_no_changes -> { @character.reload } do
        assert_no_difference -> { @character.reload.sessions.count } do
          assert_no_enqueued_jobs only: [ Character::OnUpdateJob ] do
            patch settings_character_url, params: { character: { tag: "monkey-d-luffy", contact_address: "one@mugiwara.com", password: "password" } }
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
