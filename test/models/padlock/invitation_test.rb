require "test_helper"

class Padlock::InvitationTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  class IssueTest < self
    setup { @issuer = characters(:luffy) }

    test "issues an invitation with the given character as issuer" do
      freeze_time do
        assert_difference -> { Padlock::Invitation.count } do
          assert_enqueued_with(job: Padlock::Invitation::OnIssuedJob) do
            invitation = Padlock::Invitation.issue(issuer: @issuer, confirmation_password: "password")

            assert invitation.persisted?
            assert_equal @issuer, invitation.issuer
            assert_nil invitation.carrier
            assert_equal Padlock::Invitation.expires_at, invitation.expires_at
          end
        end
      end
    end

    test "enqueues a job to expired the invitation" do
      freeze_time do
        assert_enqueued_with(job: Padlock::Invitation::OnIssuedJob) do
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
        assert_difference -> { Padlock::Invitation.active.count }, -1 do
          assert_enqueued_with(job: Padlock::Invitation::OnRevokedOrTornJob, args: [ @invitation ]) do
            assert @invitation.revoke(revoker: @revoker, confirmation_password:)

            assert_nil @invitation.carrier_id
          end
        end
      end
    end

    test "does not revoke the invitation when the confirmation password is invalid" do
      confirmation_password = "invalid_password"

      freeze_time do
        assert_no_difference -> { Padlock::Invitation.count } do
          assert_no_enqueued_jobs(only: Padlock::Invitation::OnRevokedOrTornJob) do
            assert_not @invitation.revoke(revoker: @revoker, confirmation_password:)

            assert_includes @invitation.errors[:confirmation_password], "is invalid"
            assert_not_nil @invitation.carrier_id
          end
        end
      end
    end

    test "does not revoke an invitation that do not have a carrier" do
      invitation = padlock_invitations(:pending_invitation)
      confirmation_password = "password"

      assert_no_difference -> { Padlock::Invitation.active.count } do
        assert_no_enqueued_jobs(only: Padlock::Invitation::OnRevokedOrTornJob) do
          assert_raises Padlock::Invitation::NonRevocableError do
            invitation.revoke(revoker: @revoker, confirmation_password:)
          end
        end
      end
    end
  end

  class TearTest < self
    setup { @invitation = padlock_invitations(:pending_invitation) }

    test "destroys the pending invitation" do
      assert_difference -> { Padlock::Invitation.active.count }, -1 do
        assert_enqueued_with(job: Padlock::Invitation::OnRevokedOrTornJob, args: [ @invitation ]) do
          assert @invitation.tear
        end
      end
    end

    test "does not destroy the accepted invitation" do
      invitation = padlock_invitations(:zoro_invitation)

      assert_no_difference -> { Padlock::Invitation.active.count } do
        assert_no_enqueued_jobs(only: Padlock::Invitation::OnRevokedOrTornJob) do
          assert_raise Padlock::Invitation::NonTearableError do
            assert_not invitation.tear
          end
        end
      end
    end
  end

  class ClaimTest < self
    setup { @invitation = padlock_invitations(:pending_invitation) }

    test "claims the invitation" do
      @params = ActionController::Parameters.new({
                                                   padlock_invitation: {
                                                     carrier: {
                                                       tag: "sun-of-the-sea-jimbe",
                                                       contact_address: "jimbe@mugiwara.com",
                                                       password_padlock: {
                                                         key: "password",
                                                         key_confirmation: "password"
                                                       }
                                                     }
                                                   }
                                                 })

      assert_difference -> { Padlock::Invitation.claimable.count }, -1 do
        assert_difference -> { Padlock::Password.active.count }, 1 do
          assert_difference -> { BossKey.active.count }, 2 do
            assert_difference -> { Character.count }, 1 do
              assert_enqueued_with(job: Padlock::Invitation::OnClaimedJob, args: [ @invitation ]) do
                assert @invitation.claim(padlock_invitation_params)
              end
            end
          end
        end
      end
    end

    test "does not claim the invitation when the carrier is invalid" do
      @params = ActionController::Parameters.new({
                                                   padlock_invitation: {
                                                     carrier: {
                                                       tag: "monkey-d-luffy",
                                                       contact_address: "jimbe@mugiwara.com",
                                                       password_padlock: {
                                                         key: "password",
                                                         key_confirmation: "password"
                                                       }
                                                     }
                                                   }
                                                 })

      assert_no_difference -> { Padlock::Invitation.claimable.count } do
        assert_no_difference -> { Padlock::Password.active.count } do
          assert_no_difference -> { BossKey.active.count } do
            assert_no_difference -> { Character.count } do
              assert_no_enqueued_jobs do
                assert_not @invitation.claim(padlock_invitation_params)
              end
            end
          end
        end
      end
    end

    test "does not claim the invitation when the carrier password padlock is invalid" do
      @params = ActionController::Parameters.new({
                                                   padlock_invitation: {
                                                     carrier: {
                                                       tag: "sun-of-the-sea-jimbe",
                                                       contact_address: "jimbe@mugiwara.com",
                                                       password_padlock: {
                                                         key: "password",
                                                         key_confirmation: "invalid-password"
                                                       }
                                                     }
                                                   }
                                                 })

      assert_no_difference -> { Padlock::Invitation.claimable.count } do
        assert_no_difference -> { Padlock::Password.active.count } do
          assert_no_difference -> { BossKey.active.count } do
            assert_no_difference -> { Character.count } do
              assert_no_enqueued_jobs do
                assert_not @invitation.claim(padlock_invitation_params)
              end
            end
          end
        end
      end
    end

    test "does not allow to claim an expired invitation" do
      @params = ActionController::Parameters.new({})
      invitation = padlock_invitations(:expired_invitation)

      assert_no_difference -> { Padlock::Invitation.claimable.count } do
        assert_no_difference -> { Padlock::Password.active.count } do
          assert_no_difference -> { BossKey.active.count } do
            assert_no_difference -> { Character.count } do
              assert_no_enqueued_jobs do
                assert_raise Padlock::Invitation::NonClaimableError, match: /has expired/ do
                  invitation.claim(padlock_invitation_params)
                end
              end
            end
          end
        end
      end
    end

    test "does not allow to claim a claimed invitation" do
      @params = ActionController::Parameters.new({})
      invitation = padlock_invitations(:zoro_invitation)

      assert_no_difference -> { Padlock::Invitation.claimable.count } do
        assert_no_difference -> { Padlock::Password.active.count } do
          assert_no_difference -> { BossKey.active.count } do
            assert_no_difference -> { Character.count } do
              assert_no_enqueued_jobs do
                assert_raise Padlock::Invitation::NonClaimableError, match: /is claimed by another carrier/ do
                  invitation.claim(padlock_invitation_params)
                end
              end
            end
          end
        end
      end
    end

    private

    def padlock_invitation_params
      @params.fetch(:padlock_invitation, {}).permit(carrier: [ :tag, :contact_address, password_padlock: [ :key, :key_confirmation ] ])
    end
  end
end
