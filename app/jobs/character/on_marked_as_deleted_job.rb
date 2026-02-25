class Character::OnMarkedAsDeletedJob < ApplicationJob
  queue_as :default

  def perform(character, deletion_timestamp)
    return :no_character_received unless character.present?
    return :no_deletion_time_received unless deletion_timestamp.present?
    return :old_deletion_timestamp_received if character.updated_at > deletion_timestamp

    updated = false
    deactivation_token = SecureRandom.uuid

    character.transaction do
      # The Padlock::Password configuration will ensure that all previous padlocks are destroyed as well.
      character.password_padlock&.destroy!
      character.sessions.find_each(&:destroy!)

      character.update!(
        tag: "deleted-character-#{deactivation_token}",
        contact_address: character.contact_address.gsub(/@/, "-deactivated-#{deactivation_token}@"),
        deleted_at: deletion_timestamp
      )

      updated = true
    rescue StandardError => e
      Rails.logger.debug e.message
      Rails.logger.debug e.backtrace.join("\n")

      raise ActiveRecord::Rollback
    end

    if updated
      :character_deleted
    else
      :character_not_deleted
    end
  end
end
