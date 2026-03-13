require "test_helper"

class Settings::InvitationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @character = characters(:luffy)
    sign_in_as @character
  end

  test "should get index" do
    get settings_invitations_url
    assert_response :success
  end

  # This
  test "should create settings_invitation" do
    assert_difference -> { Padlock::Invitation.where(issuer: @character).count }, 1 do
      post settings_invitations_url
    end

    assert_redirected_to settings_invitations_url
  end

  test "should show settings_invitation" do
    get settings_invitation_url(@invitation)
    assert_response :success
  end

  test "should destroy settings_invitation" do
    assert_difference("Settings::Invitation.count", -1) do
      delete settings_invitation_url(@invitation)
    end

    assert_redirected_to settings_invitations_url
  end
end
