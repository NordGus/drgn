require "test_helper"

class Settings::InvitationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @invitation = settings_invitations(:one)
  end

  test "should get index" do
    get settings_invitations_url
    assert_response :success
  end

  test "should get new" do
    get new_settings_invitation_url
    assert_response :success
  end

  test "should create settings_invitation" do
    assert_difference("Settings::Invitation.count") do
      post settings_invitations_url, params: { invitation: {} }
    end

    assert_redirected_to settings_invitation_url(Settings::Invitation.last)
  end

  test "should show settings_invitation" do
    get settings_invitation_url(@invitation)
    assert_response :success
  end

  test "should get edit" do
    get edit_settings_invitation_url(@invitation)
    assert_response :success
  end

  test "should update settings_invitation" do
    patch settings_invitation_url(@invitation), params: { invitation: {} }
    assert_redirected_to settings_invitation_url(@invitation)
  end

  test "should destroy settings_invitation" do
    assert_difference("Settings::Invitation.count", -1) do
      delete settings_invitation_url(@invitation)
    end

    assert_redirected_to settings_invitations_url
  end
end
