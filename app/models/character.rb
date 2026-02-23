class Character < ApplicationRecord
  normalizes :tag, with: ->(t) { t.strip.split(" ").reject(&:blank?).join(" ") }
  normalizes :contact_address, with: ->(t) { t.strip.downcase.strip.split(" ").reject(&:blank?).join("") }

  validates :tag, presence: true, uniqueness: true
  validates :contact_address, presence: true, uniqueness: true, email: true
  validates :deleted_at, comparison: { less_than_or_equal_to: Time.current + 1.minute }, if: :deleted_at
  # We validate that the password_padlock is unlocked only when is done from a dangerous action; otherwise it's unnecessary.
  validate :password_padlock_must_be_unlocked, if: -> { updated_from_dangerous_action }

  encrypts :tag, deterministic: true, ignore_case: true
  encrypts :contact_address, deterministic: true, downcase: true

  has_many :sessions, inverse_of: :character, dependent: :destroy

  has_one :password_padlock, -> { active }, class_name: "Padlock::Password", foreign_key: :character_id, dependent: :destroy
  has_many :previous_password_padlocks, -> { replaced }, class_name: "Padlock::Password", foreign_key: :character_id, dependent: :destroy

  attribute :password, :string, default: nil
  # This flag is used to control whether the character is updated from a dangerous action or not. This is used to control
  # the validation whether the character's password padlock is unlocked or not.
  attribute :updated_from_dangerous_action, :boolean, default: false

  scope :active, -> { where(deleted_at: nil) }

  def update_sheet(attributes)
    update_outcome = false

    transaction do
      close_remote_connections

      sessions.delete_all

      update!(attributes.to_h.merge(
        updated_from_dangerous_action: true
      ))

      update_outcome = true

      OnSheetUpdatedJob.perform_later(self, Time.current)
    rescue StandardError => e
      Rails.logger.debug e.message
      Rails.logger.debug e.backtrace.join("\n")

      raise ActiveRecord::Rollback
    end

    update_outcome
  end

  def mark_as_deleted(attributes)
    update_outcome = false

    transaction do
      close_remote_connections

      # We delete all sessions to prevent any further connection.
      sessions.delete_all

      update!(attributes.to_h.merge(
        updated_from_dangerous_action: true,
        # By marking the character as deleted, we also prevent login padlocks from being unlocked.
        deleted_at: Time.current
      ))

      update_outcome = true

      OnMarkedAsDeletedJob.perform_later(self, Time.current)
    rescue StandardError => e
      Rails.logger.debug e.message
      Rails.logger.debug e.backtrace.join("\n")

      raise ActiveRecord::Rollback
    end

    update_outcome
  end

  private

  def password_padlock_must_be_unlocked
    errors.add(:password, :invalid) unless password_padlock.unlock_for_dangerous_action(password)
  end

  def close_remote_connections(reconnect: false)
    ActionCable.server.remote_connections.where(current_character: self).disconnect reconnect:
  end
end
