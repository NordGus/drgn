class Padlock::Password::OnUnlockedJob < ApplicationJob
  queue_as :default

  retry_on ActiveRecord::RecordNotUnique, ActiveRecord::RecordNotSaved, wait: 3.seconds, attempts: 3, report: true

  discard_on ActiveRecord::RecordNotFound

  def perform(padlock, unlocked_by, last_unlocked_at)
    return :no_padlock_received unless padlock.present?
    return :inactive_padlock_received unless padlock.still_active?

    # save the last action to have unlocked the padlock and at what moment
    padlock.update!(unlocked_by:, last_unlocked_at:)
  end
end
