require "test_helper"

class Settings::BossKeysControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get settings_boss_keys_index_url
    assert_response :success
  end

  test "should get show" do
    get settings_boss_keys_show_url
    assert_response :success
  end

  test "should get update" do
    get settings_boss_keys_update_url
    assert_response :success
  end
end
