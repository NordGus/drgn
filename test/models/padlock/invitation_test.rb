require "test_helper"

class Padlock::InvitationTest < ActiveSupport::TestCase
  class IssueTest < self
    include ActiveJob::TestHelper

    setup { @issuer = characters(:luffy) }

    test "issues an invitation with the given character as issuer" do
      freeze_time do
        assert_difference -> { Padlock::Invitation.count } do
          invitation = Padlock::Invitation.issue(issuer: @issuer)

          assert invitation.persisted?
          assert_equal @issuer, invitation.issuer
          assert_nil invitation.carrier
          assert_equal Padlock::Invitation.expires_at, invitation.expires_at
        end
      end
    end

    test "enqueues a job to expired the invitation" do
      freeze_time do
        at_matcher = ->(job_at) { (Padlock::Invitation.expires_at - 1.minute...Padlock::Invitation.expires_at + 1.minute).cover?(job_at) }

        assert_enqueued_with(job: Padlock::Invitation::OnExpiredJob, at: at_matcher) do
          invitation = Padlock::Invitation.issue(issuer: @issuer)

          assert invitation.persisted?
        end
      end
    end
  end
end
