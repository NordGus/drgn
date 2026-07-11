require "test_helper"

class Settings::PostOfficesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @settings_post_office = settings_post_offices(:one)
  end

  test "should get index" do
    get settings_post_offices_url
    assert_response :success
  end

  test "should get new" do
    get new_settings_post_office_url
    assert_response :success
  end

  test "should create settings_post_office" do
    assert_difference("Settings::PostOffice.count") do
      post settings_post_offices_url, params: { settings_post_office: {} }
    end

    assert_redirected_to settings_post_office_url(Settings::PostOffice.last)
  end

  test "should show settings_post_office" do
    get settings_post_office_url(@settings_post_office)
    assert_response :success
  end

  test "should get edit" do
    get edit_settings_post_office_url(@settings_post_office)
    assert_response :success
  end

  test "should update settings_post_office" do
    patch settings_post_office_url(@settings_post_office), params: { settings_post_office: {} }
    assert_redirected_to settings_post_office_url(@settings_post_office)
  end

  test "should destroy settings_post_office" do
    assert_difference("Settings::PostOffice.count", -1) do
      delete settings_post_office_url(@settings_post_office)
    end

    assert_redirected_to settings_post_offices_url
  end
end
