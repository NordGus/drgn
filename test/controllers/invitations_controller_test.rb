require "test_helper"

class InvitationsControllerTest < ActionDispatch::IntegrationTest
  setup { @invitation = padlock_invitations(:pending_invitation) }

  test "should show the character creator" do
    get invitation_url(key: @invitation.key)
    assert_response :success
  end

  test "should not show the character creator for an expired invitation" do
    invitation = padlock_invitations(:expired_invitation)

    get invitation_url(key: invitation.key)
    assert_redirected_to new_session_url
  end

  test "should not show the character creator for an taken invitation" do
    invitation = padlock_invitations(:zoro_invitation)

    get invitation_url(key: invitation.key)
    assert_redirected_to new_session_url
  end
end
