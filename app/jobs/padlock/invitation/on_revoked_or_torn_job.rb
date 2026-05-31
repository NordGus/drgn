class Padlock::Invitation::OnRevokedOrTornJob < ApplicationJob
  queue_as :default

  limits_concurrency to: 1, key: ->(invitation) { invitation }, duration: 1.minute, group: "PadlockActions"

  # Just in case something goes wrong during development. If this is happening on a production deployment something has
  # gone catastrophically wrong
  retry_on ActionView::MissingTemplate, wait: 5.seconds, attempts: 10, report: true
  retry_on ActiveRecord::RecordNotDestroyed, ActiveRecord::RecordInvalid, wait: 5.seconds, attempts: :unlimited, report: true

  discard_on ActiveRecord::RecordNotFound

  def perform(invitation)
    return :no_invitation_received unless invitation.present?
    return :claimed_invitation_received if invitation.claimed?
    return :non_deleted_invitation_received if invitation.active?

    invitation.destroy! # If we have reached this point we assumed the invitation can be destroyed

    # With the invitation deleted we can procee
    Character::OnMarkedAsDeletedJob.perform_later(invitation.holder, invitation.deleted_at)

    # Using the BossKey::Recruiter feature we just need to broadcast that the invitation was revoked to the party members
    # with access to the Invitations BossDoor.
    #
    # Because we are inside a background job, and because of our engineering tradeoff, this iteration does not represent
    # a performance problem.
    BossKey::Recruiter.with_whom_can_be_broadcasted.find_each do |key|
      # We remove the invitation from the accepted invitations list
      Padlock::InvitationChannel.broadcast_remove_to(key.holder, target: invitation)
    end

    :inactive_invitation_processed
  end
end
