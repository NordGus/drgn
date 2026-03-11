require "test_helper"

class Padlock::Invitation::OnIssuedJobTest < ActiveJob::TestCase
  test "does nothing when not receiving an invitation" do
    assert_no_changes -> { Padlock::Invitation.count } do
      assert_equal :no_invitation_received, Padlock::Invitation::OnIssuedJob.perform_now(nil)
    end
  end

  test "does nothing when the invitation is already accepted" do
    invitation = padlock_invitations(:zoro_invitation)

    assert_no_changes -> { Padlock::Invitation.count } do
      assert_equal :invitation_in_use, Padlock::Invitation::OnIssuedJob.perform_now(invitation)
    end
  end

  test "throws an error when the invitation is still alive so it can be retried" do
    invitation = padlock_invitations(:pending_invitation)

    assert_no_changes -> { Padlock::Invitation.count } do
      assert_raises Padlock::Invitation::OnIssuedJob::StillAliveError, match: /invitation hasn't expired yet/ do
        Padlock::Invitation::OnIssuedJob.new.perform(invitation)
      end
    end
  end

  test "destroys expired unused invitations" do
    invitation = padlock_invitations(:expired_invitation)

    assert_difference -> { Padlock::Invitation.count }, -1 do
      assert Padlock::Invitation::OnIssuedJob.perform_now(invitation)
    end
  end
end
