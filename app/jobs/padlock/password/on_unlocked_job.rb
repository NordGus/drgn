class Padlock::Password::OnUnlockedJob < ApplicationJob
  queue_as :default
  limits_concurrency to: 1, key: ->(padlock, *) { padlock }, duration: 1.minute, group: "PadlockActions"

  retry_on ActiveRecord::RecordNotUnique, ActiveRecord::RecordNotSaved, wait: 3.seconds, attempts: 3, report: true

  discard_on ActiveRecord::RecordNotFound

  def perform(padlock, unlocked_by, last_unlocked_at)
    return :no_padlock_received unless padlock.present?
    return :inactive_padlock_received unless padlock.still_active?
    return :old_unlocked_timestamp_received if padlock.last_unlocked_at.present? && padlock.last_unlocked_at > last_unlocked_at

    # save the last action to have unlocked the padlock and at what moment
    padlock.update!(unlocked_by:, last_unlocked_at:)
  end
end
