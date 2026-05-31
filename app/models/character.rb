##
# Character is a record that represent a user inside the platform.
#
# A Character cannot be deleted, only marked as deleted action which cleans the record while maintaining relevant
# information in the platform.
class Character < ApplicationRecord
  include PasswordLockable

  validates :tag, presence: true, uniqueness: true
  validates :contact_address, presence: true, uniqueness: true, email: true

  has_many :boss_keys, foreign_key: :holder_id, inverse_of: :holder, dependent: :restrict_with_error

  scope :active, -> { where(deleted_at: nil) }
  scope :playable, -> { where(type: %w[Character::DungeonMaster Character::Adventurer]) }

  before_destroy :prevent_deletion

  def update_sheet(attributes)
    update_outcome = false

    assign_attributes(attributes.except(:confirmation_password))

    return true unless changed?

    transaction do
      close_remote_connections

      sessions.destroy_all if respond_to?(:sessions)

      update!(attributes.to_h.merge(from_dangerous_action: true))

      update_outcome = true
    rescue StandardError => e
      Rails.logger.debug e.message
      Rails.logger.debug e.backtrace.join("\n")

      raise ActiveRecord::Rollback
    end

    OnSheetUpdatedJob.perform_later(self, Time.current) if update_outcome

    update_outcome
  end

  def mark_as_deleted(attributes)
    update_outcome = false
    current_time = Time.current

    transaction do
      # We delete all sessions to prevent any further connection.
      sessions.destroy_all if respond_to?(:sessions)
      boss_keys.update_all(deleted_at: current_time, updated_at: current_time)

      update!(attributes.to_h.merge(
        from_dangerous_action: true,
        # By marking the character as deleted, we also prevent login padlocks from being unlocked.
        deleted_at: current_time
      ))

      update_outcome = true
    rescue StandardError => e
      Rails.logger.debug e.message
      Rails.logger.debug e.backtrace.join("\n")

      raise ActiveRecord::Rollback
    end

    if update_outcome
      close_remote_connections

      OnMarkedAsDeletedJob.perform_later(self, current_time)
    end

    update_outcome
  end

  # Expel the character from the party. This is the same as marking the character as deleted but is used on the
  # invitation subsystem to remove the character from the platform by an administrator.
  #
  # @note This method is not idempotent. It will only expel the character once.
  # @note This method is not transactional, so it should only be called within a transaction.
  # @note This method is supposed to be only called by an administrator inside Invitation#revoke.
  def expel_from_party!
    current_time = Time.current

    close_remote_connections

    # We delete all sessions to prevent any further connection.
    sessions.destroy_all

    update!(deleted_at: current_time)
    boss_keys.update_all(deleted_at: current_time, updated_at: current_time)
  end

  # Returns whether the Character is the Dungeon Master
  #
  # @return Boolean
  def is_dungeon_master?
    type == "Character::DungeonMaster"
  end

  # Returns whether the Character is marked as deleted
  #
  # @return Boolean
  def active?
    deleted_at.nil?
  end

  private

  def record_was_unlocked?
    false
  end

  def close_remote_connections(reconnect: false)
    ActionCable.server.remote_connections.where(current_character: self).disconnect reconnect:
  end

  def prevent_deletion
    error.add(:base, "Characters are permanent records and cannot be deleted")

    throw :abort
  end
end
