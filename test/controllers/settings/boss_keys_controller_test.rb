require "test_helper"

class Settings::BossKeysControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get settings_boss_keys_url
    assert_response :success
  end

  test "should get update" do
    put settings_boss_key_url
    assert_response :see_other
  end
end
