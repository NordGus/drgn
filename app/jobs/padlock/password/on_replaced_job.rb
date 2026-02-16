class Padlock::Password::OnReplacedJob < ApplicationJob
  queue_as :default
  limits_concurrency to: 1, key: ->(padlock, *) { padlock }, duration: 1.minute, group: "PadlockActions"

  retry_on ActiveRecord::RecordNotDestroyed, wait: 3.seconds, attempts: 10, report: true

  discard_on ActiveRecord::RecordNotFound

  def perform(padlock)
    return :no_padlock_received unless padlock.present?

    max_history_length = Padlock::Password.max_history_length
    character = padlock.character

    previous_padlocks = character.previous_password_padlocks.limit(max_history_length).limit(max_history_length).to_a

    # If the number of previous padlocks is less than the max history length, then there is no need to delete anything.
    # Only when the character's previous padlocks reach the max history length will we need to delete the oldest padlock.
    return :history_has_not_been_exhausted if previous_padlocks.size < max_history_length

    # We only delete the last padlock because is outside the new maximum length of password padlocks for the character,
    # because let's remember that the user has a password under password_padlock that we are not seeing here. So by
    # limiting previous_password_padlocks to max_history_length, we are effectively taking the oversized history to trim
    # it down to the max length by deleting the oldest padlock in the limit.
    #
    # We do not need to delete more than the last padlock, because the dependency association _replaced_padlock will
    # recursively destroy the padlocks below it in the history.
    previous_padlocks.last.destroy!
  end
end
