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

    # With the invitation deleted we can proceed to mark the holder as deleted
    Character::OnMarkedAsDeletedJob.perform_later(invitation.holder, invitation.deleted_at)

    # We broadcast the deletion to the ui
    Padlock::InvitationChannel.broadcast_torn_or_revoked(invitation)

    :inactive_invitation_processed
  end
end
