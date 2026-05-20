##
# Padlock::Invitation::OnIssuedJob is a job that is enqueued when an invitation has been successfully issued. It handles
# all additional actions that are not required to be done synchronously while issuing the invitation.
#
# In this case:
#   1. Enqueue the Invitation expiration job.
#   2. Broadcast the action into_
class Padlock::Invitation::OnIssuedJob < ApplicationJob
  queue_as :default

  limits_concurrency to: 1, key: ->(invitation) { invitation }, duration: 1.minute, group: "PadlockActions"

  # Just in case something goes wrong during development. If this is happening on a production deployment something has
  # gone catastrophically wrong
  retry_on ActionView::MissingTemplate, wait: 5.seconds, attempts: 10, report: true

  discard_on ActiveRecord::RecordNotFound

  def perform(invitation)
    return :no_invitation_received unless invitation.present?
    # To prevent weird behaviors when the queues are congested, and it was claimed before this job runs, we return
    # earlier because all this work is no longer necessary.
    return :invitation_in_use if invitation.carrier_id.present?

    # We enqueue the expiration job so the invitation is removed from the platform to prevent zombie invitations hanging
    # out leaving a security gap in the invitation system.
    Padlock::Invitation::OnExpiredJob.set(wait_until: invitation.expires_at).perform_later(invitation)

    # Using the BossKey::Recruiter feature we just need to broadcast that the invitation was issued to the party members
    # with access to the Invitations BossDoor.
    #
    # Because we are inside a background job, and because of our engineering tradeoff, this iteration does not represent
    # a performance problem.
    BossKey::Recruiter.with_whom_can_be_broadcasted.find_each do |key|
      Padlock::InvitationChannel.broadcast_action_to(
        key.holder,
        action: :prepend,
        target: "pending_invitations",
        partial: "settings/invitations/invitation",
        locals: { invitation:, current_time: Time.current, current_character: key.holder }
      )
    end

    :issued_invitation_processed
  end
end
