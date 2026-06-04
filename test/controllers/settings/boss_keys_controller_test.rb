require "test_helper"

class Settings::BossKeysControllerTest < ActionDispatch::IntegrationTest
  class WithAnAuthorizedCharacter < self
    setup do
      @character = character_adventurers(:nami)
      sign_in_as @character
    end

    test "should list all updatable keys" do
      get settings_boss_keys_url
      assert_response :success
    end

    test "should update other character's keys" do
      key = boss_key_recruiters(:zoro_recruiter_key)

      assert_changes -> { key.reload.access_level }, from: "no", to: "share" do
        put settings_boss_key_url(key), params: { boss_key: { access_level: "share", confirmation_password: "password" } }

        assert_response :see_other
      end
    end

    test "should not be able to update their own access levels" do
      key = boss_key_recruiters(:nami_recruiter_key)

      assert_no_changes -> { key.reload.access_level } do
        put settings_boss_key_url(key), params: { boss_key: { access_level: "share", confirmation_password: "password" } }

        assert_response :not_found
      end
    end

    test "should not be able to update the dungeon's master access levels" do
      key = boss_key_recruiters(:luffys_recruiter_key)

      assert_no_changes -> { key.reload.access_level } do
        put settings_boss_key_url(key), params: { boss_key: { access_level: "share", confirmation_password: "password" } }

        assert_response :not_found
      end
    end
  end

  class WithAnUnauthorizedCharacter < self
    setup do
      @character = character_adventurers(:kinemon)
      sign_in_as @character
    end

    test "should not be allow to list any keys" do
      get settings_boss_keys_url
      assert_redirected_to root_path
    end

    test "should not be allow to update any key" do
      key = boss_key_recruiters(:luffys_recruiter_key)

      assert_no_changes -> { key.reload.access_level } do
        put settings_boss_key_url(key), params: { boss_key: { access_level: "share", confirmation_password: "password" } }

        assert_redirected_to root_path
      end
    end
  end
end
