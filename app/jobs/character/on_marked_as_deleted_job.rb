class Character::OnMarkedAsDeletedJob < ApplicationJob
  queue_as :default

  class FailedToDeletedCharacterError < StandardError; end

  retry_on FailedToDeletedCharacterError, wait: 5.minutes, attempts: :unlimited, report: true

  discard_on ActiveRecord::RecordNotFound

  def perform(character, deletion_timestamp)
    return :no_character_received unless character.present?
    return :no_deletion_time_received unless deletion_timestamp.present?
    return :old_deletion_timestamp_received if character.updated_at > deletion_timestamp
    return :non_deleted_character_received if character.active?

    updated = false
    deactivation_token = SecureRandom.uuid
    boss_keys = character.boss_keys.to_a

    character.transaction do
      # The Padlock::Password configuration will ensure that all previous padlocks are destroyed as well.
      character.password_padlock&.destroy!
      character.sessions.destroy_all
      character.boss_keys.destroy_all

      character.update!(
        tag: "deleted-character-#{deactivation_token}",
        contact_address: character.contact_address.gsub(/@/, "-deactivated-#{deactivation_token}@")
      )

      updated = true
    rescue StandardError => e
      Rails.logger.debug e.message
      Rails.logger.debug e.backtrace.join("\n")

      raise ActiveRecord::Rollback
    end

    fail FailedToDeletedCharacterError, self unless updated

    # In case the character was kicked out of the party we stream a refresh of their current view
    ApplicationCable::StreamsChannel.broadcast_refresh_to(character)
    ApplicationCable::StreamsChannel.broadcast_refresh_to(:settings, character)
    # We also need to broadcast the removal of their boss keys
    BossKeyChannel.broadcast_holder_marked_as_deleted(boss_keys)

    :character_deleted
  end
end
