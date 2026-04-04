class Character < ApplicationRecord
  EXPULSION_TIME_OFFSET = 2.minutes.freeze

  include PasswordLockable

  normalizes :tag, with: ->(t) { t.strip.split(" ").reject(&:blank?).join(" ") }
  normalizes :contact_address, with: ->(t) { t.strip.downcase.strip.split(" ").reject(&:blank?).join("") }

  validates :tag, presence: true, uniqueness: true
  validates :contact_address, presence: true, uniqueness: true, email: true
  validates :deleted_at, comparison: { less_than_or_equal_to: Time.current + 1.minute }, if: :deleted_at

  encrypts :tag, deterministic: true, ignore_case: true
  encrypts :contact_address, deterministic: true, downcase: true

  has_many :sessions, inverse_of: :character, dependent: :destroy

  has_one :password_padlock, -> { active }, class_name: "Padlock::Password", foreign_key: :character_id, dependent: :destroy
  has_many :previous_password_padlocks, -> { replaced }, class_name: "Padlock::Password", foreign_key: :character_id, dependent: :destroy

  has_many :issued_invitations, class_name: "Padlock::Invitation", foreign_key: :issuer_id, dependent: :destroy
  has_one :invitation, class_name: "Padlock::Invitation", foreign_key: :carrier_id, dependent: :destroy

  scope :active, -> { where(deleted_at: nil) }

  def update_sheet(attributes)
    update_outcome = false

    assign_attributes(attributes.except(:confirmation_password))

    return true unless changed?

    transaction do
      close_remote_connections

      sessions.delete_all

      update!(attributes.to_h.merge(from_dangerous_action: true))

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
        from_dangerous_action: true,
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

  # Expel the character from the party. This is the same as marking the character as deleted but is used on the
  # invitation subsystem to remove the character from the platform by an administrator.
  #
  # @note This method is not idempotent. It will only expel the character once.
  # @note This method is not transactional, so it should only be called within a transaction.
  # @note This method is supposed to be only called by an administrator inside Invitation#revoke.
  def expel_from_party!
    close_remote_connections

    # We delete all sessions to prevent any further connection.
    sessions.destroy_all

    update!(deleted_at: Time.current)

    # We delay the deletion of the character by a few minutes to allow the surrounding transaction to complete.
    OnMarkedAsDeletedJob.set(wait_until: EXPULSION_TIME_OFFSET.from_now).perform_later(self, Time.current)
  end

  private

  def must_be_unlocked
    errors.add(:confirmation_password, :invalid) unless password_padlock.unlock_for_dangerous_action(confirmation_password)
  end

  def close_remote_connections(reconnect: false)
    ActionCable.server.remote_connections.where(current_character: self).disconnect reconnect:
  end
end
