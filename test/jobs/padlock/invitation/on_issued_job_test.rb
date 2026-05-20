require "test_helper"

class Padlock::Invitation::OnIssuedJobTest < ActiveJob::TestCase
  include ActionCable::TestHelper

  setup { @character_with_access_to_invitations = characters(:luffy) }

  test "does nothing when not receiving an invitation" do
    assert_no_enqueued_jobs do
      assert_no_broadcasts(@character_with_access_to_invitations.to_gid_param) do
        assert_equal :no_invitation_received, Padlock::Invitation::OnIssuedJob.perform_now(nil)
      end
    end
  end

  test "does nothing when the invitation is already accepted" do
    invitation = padlock_invitations(:zoro_invitation)

    assert_no_enqueued_jobs do
      assert_no_broadcasts(@character_with_access_to_invitations.to_gid_param) do
        assert_equal :invitation_in_use, Padlock::Invitation::OnIssuedJob.perform_now(invitation)
      end
    end
  end

  test "perform all background tasks required after issuing an invitation" do
    invitation = padlock_invitations(:pending_invitation)

    freeze_time do
      assert_enqueued_with(job: Padlock::Invitation::OnExpiredJob, at: invitation.expires_at, args: [ invitation ]) do
        assert_broadcasts(@character_with_access_to_invitations.to_gid_param, 1) do
          assert_equal :issued_invitation_processed, Padlock::Invitation::OnIssuedJob.perform_now(invitation)
        end
      end
    end
  end
end
