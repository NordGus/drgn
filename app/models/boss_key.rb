##
# BossKey represents the permissions a character has to the different protected features of DRGN.
#
# @note As long a holder all required BossKey required by the system exists
# @note All children of this model, meaning implementations, must understant that access_level 0 means no access.
class BossKey < ApplicationRecord
  include PasswordLockable

  belongs_to :holder, class_name: "Character", foreign_key: :holder_id

  validates :access_level, presence: true
  validates :holder_id, presence: true, uniqueness: { scope: :type }
  validates :type, presence: true

  scope :deleted, -> { where.not(deleted_at: nil) }
  scope :active, -> { where(deleted_at: nil) }

  # attribute used to unlock the record with dangerous actions
  attribute :manager, type: :character, default: nil

  def can_access?
    fail NotImplementedError, "each BossKey must implement the #can_access? method"
  end

  def settings_controller_name
    fail NotImplementedError, "each BossKey must implement the #settings_controller_name method"
  end

  def update_access(manager:, attributes:)
    update_access_outcome = false

    transaction do
      prevent_access_modification_for_dungeon_master!

      update!(attributes.to_h.merge(
        from_dangerous_action: true,
        manager:,
      ))

      update_access_outcome = true
    rescue StandardError => e
      Rails.logger.debug e.message
      Rails.logger.debug e.backtrace.join("\n")

      raise ActiveRecord::Rollback
    end

    OnAccessUpdatedJob.perform_later(self, updated_access_direction:) if update_access_outcome

    update_access_outcome
  end

  private

  def must_be_unlocked
    errors.add(:confirmation_password, :invalid) unless manager.password_padlock.unlock_for_dangerous_action(confirmation_password)
  end

  def prevent_access_modification_for_dungeon_master!
    return unless holder.is_dungeon_master?

    errors.add(:role, "The dungeon master role must have access to everything!")

    fail ActiveRecord::RecordInvalid, self
  end

  def updated_access_direction
    return :access_removed if access_level_changed? && with_no_access?
    return :access_downgraded if self.class.access_levels[access_level_previously_was] > self.class.access_levels[access_level]
    return :access_upgraded if self.class.access_levels[access_level_previously_was] < self.class.access_levels[access_level]

    :access_level_unmodified
  end
end
