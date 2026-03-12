class Padlock::Invitation::OnExpiredJob < ApplicationJob
  queue_as :default

  retry_on Padlock::Invitation::StillAliveError, wait: 5.seconds, attempts: :unlimited, report: true
  retry_on ActiveRecord::RecordNotDestroyed, wait: 5.minutes, attempts: :unlimited, report: true

  discard_on ActiveRecord::RecordNotFound

  def perform(invitation)
    return :no_invitation_received unless invitation.present?
    return :invitation_in_use if invitation.carrier_id.present?

    # We throw an error that has a retry_on configuration if the invitation hasn't expired yet, so it's retried until
    # any of the previous guard clauses passes or the invitation has expired.
    fail Padlock::Invitation::StillAliveError, "invitation hasn't expired yet" if invitation.expires_at > Time.current

    # We destroy the issued invitation as a security measure to prevent it from being used. This is so there are no
    # zombie invitations in the database that could be used to create a new character without the knowledge of the
    # issuer.
    invitation.destroy!
  end
end
