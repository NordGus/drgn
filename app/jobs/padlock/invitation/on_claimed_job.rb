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

    # Using the BossKey::Recruiter feature we just need to broadcast that the invitation was claimed to the party members
    # with access to the Invitations BossDoor.
    #
    # Because we are inside a background job, and because of our engineering tradeoff, this iteration does not represent
    # a performance problem.
    BossKey::Recruiter.with_whom_can_be_broadcasted.find_each do |key|
      # We remove the invitation from the pending invitations list
      Padlock::InvitationChannel.broadcast_remove_to(key.holder, target: invitation)

      # We prepend the claimed invitation to the accepted invitations list
      Padlock::InvitationChannel.broadcast_action_to(
        key.holder,
        action: :prepend,
        target: "accepted_invitations",
        partial: "settings/invitations/invitation",
        locals: { invitation:, current_time: Time.current, current_character: key.holder }
      )
    end

    :claimed_invitation_processed
  end
end
