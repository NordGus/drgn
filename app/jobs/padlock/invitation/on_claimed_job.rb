class Padlock::Invitation::OnClaimedJob < ApplicationJob
  queue_as :default

  limits_concurrency to: 1, key: ->(invitation) { invitation }, duration: 1.minute, group: "PadlockActions"

  # Just in case something goes wrong during development. If this is happening on a production deployment something has
  # gone catastrophically wrong
  retry_on ActionView::MissingTemplate, wait: 5.seconds, attempts: 10, report: true

  discard_on ActiveRecord::RecordNotFound

  def perform(invitation)
    return :no_invitation_received unless invitation.present?
    return :unclaimed_invitation_received unless invitation.claimed?

    # We broadcast the state change to all channels that requires.
    Padlock::InvitationChannel.broadcast_claimed(invitation)

    :claimed_invitation_processed
  end
end
