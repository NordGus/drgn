require "test_helper"

class Padlock::InvitationTest < ActiveSupport::TestCase
  class IssueTest < self
    include ActiveJob::TestHelper

    setup { @issuer = characters(:luffy) }

    test "issues an invitation with the given character as issuer" do
      freeze_time do
        assert_difference -> { Padlock::Invitation.count } do
          invitation = Padlock::Invitation.issue(issuer: @issuer, confirmation_password: "password")

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
          invitation = Padlock::Invitation.issue(issuer: @issuer, confirmation_password: "password")

          assert invitation.persisted?
        end
      end
    end

    test "does not issue an invitation when the confirmation password is invalid" do
      freeze_time do
        assert_no_difference -> { Padlock::Invitation.where(issuer: @issuer).count } do
          invitation = Padlock::Invitation.issue(issuer: @issuer, confirmation_password: "invalid_password")

          assert_not invitation.persisted?
          assert_includes invitation.errors[:confirmation_password], "is invalid"
        end
      end
    end
  end

  class RevokeTest < self
    setup do
      @invitation = padlock_invitations(:kunjuro_invitation)
      @revoker = characters(:luffy)
    end

    test "revokes the invitation" do
      confirmation_password = "password"

      freeze_time do
        assert_difference -> { Padlock::Invitation.count }, -1 do
          assert @invitation.revoke(revoker: @revoker, confirmation_password:)

          assert_nil @invitation.carrier_id
        end
      end
    end

    test "does not revoke the invitation when the confirmation password is invalid" do
      confirmation_password = "invalid_password"

      freeze_time do
        assert_no_difference -> { Padlock::Invitation.count } do
          assert_not @invitation.revoke(revoker: @revoker, confirmation_password:)

          assert_includes @invitation.errors[:confirmation_password], "is invalid"
          assert_not_nil @invitation.carrier_id
        end
      end
    end

    test "does not revoke an invitation that do not have a carrier" do
      invitation = padlock_invitations(:pending_invitation)
      confirmation_password = "password"

      assert_raises Padlock::Invitation::NonRevocableError do
        invitation.revoke(revoker: @revoker, confirmation_password:)
      end
    end
  end

  class TearTest < self
    setup { @invitation = padlock_invitations(:pending_invitation) }

    test "destroys the pending invitation" do
      assert_difference -> { Padlock::Invitation.count }, -1 do
        assert @invitation.tear!
      end
    end

    test "does not destroy the accepted invitation" do
      invitation = padlock_invitations(:zoro_invitation)

      assert_no_difference -> { Padlock::Invitation.count } do
        assert_raise Padlock::Invitation::NonTearableError do
          assert_not invitation.tear!
        end
      end
    end
  end
end
