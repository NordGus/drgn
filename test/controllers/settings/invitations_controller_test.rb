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

  test "should create settings_invitation" do
    assert_difference -> { Padlock::Invitation.where(issuer: @character).count }, 1 do
      post settings_invitations_url, params: { padlock_invitation: { confirmation_password: "password" } }
    end

    assert_redirected_to settings_invitations_url
  end

  test "should not create an invitation when the confirmation password is invalid" do
    assert_no_difference -> { Padlock::Invitation.where(issuer: @character).count } do
      post settings_invitations_url, params: { padlock_invitation: { confirmation_password: "invalid_password" } }
    end

    assert_response :unprocessable_entity
  end

  test "should destroy settings_invitation" do
    invitation = padlock_invitations(:pending_invitation)

    assert_difference("Padlock::Invitation.count", -1) do
      delete settings_invitation_url(invitation)
    end

    assert_redirected_to settings_invitations_url
  end
end
