class Padlock::Invitation::Recurring::ExpireOrphansJob < ApplicationJob
  queue_as :default
  limits_concurrency to: 1, key: :recurring_expire_orphans, duration: 1.minute, group: "PadlockActions"

  def perform(batch_size: 100)
    Padlock::Invitation.tearable.find_each(batch_size:) { |invitation| Padlock::Invitation::OnExpiredJob.perform_later(invitation) }

    :all_orphan_invitations_expired
  end
end
