require "test_helper"

class Padlock::Invitation::Recurring::ExpireOrphansJobTest < ActiveJob::TestCase
  setup { @tearable_invitation = padlock_invitations(:expired_invitation) }

  test "enqueues expiration jobs for all tearable invitations" do
    assert_enqueued_jobs 1, only: Padlock::Invitation::OnExpiredJob do
      assert_enqueued_with job: Padlock::Invitation::OnExpiredJob, args: [@tearable_invitation] do
        assert_equal :all_orphan_invitations_expired, Padlock::Invitation::Recurring::ExpireOrphansJob.perform_now
      end
    end
  end
end
