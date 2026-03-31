class Padlock::Invitation < ApplicationRecord
  include PasswordLockable

  KEY_LENGTH = 64.freeze

  # TODO: move these values into system configurations
  EXPIRES_IN_DAYS = 1.freeze

  class StillAliveError < StandardError; end

  class NonRevocableError < StandardError; end

  has_secure_token :key, length: KEY_LENGTH

  belongs_to :issuer, class_name: "Character", foreign_key: :issuer_id
  belongs_to :carrier, class_name: "Character", foreign_key: :carrier_id, optional: true

  validates :key, presence: true
  validates :issuer_id, presence: true
  validates :expires_at, presence: true, comparison: { greater_than_or_equal_to: -> { Time.current } }
  validates :carrier_id, uniqueness: true, if: -> { carrier_id.present? }

  scope :pending, -> { where(carrier_id: nil) }
  scope :accepted, -> { where.not(carrier_id: nil) }
  scope :active, -> { pending.where(expires_at: ..Time.current) }

  attribute :unlocked_by, type: :character, default: nil

  def self.expires_at
    # TODO: move this value into system configurations
    EXPIRES_IN_DAYS.days.from_now
  end

  # Issues a new invitation by the given issuer.
  #
  # @note This method is not idempotent, so it should only be called once per invitation.
  # @note This method is not transactional, so it should only be called within a transaction or as the only
  #   operation in an action.
  #
  # @param issuer [Character] issuer of the invitation.
  #
  # @return [Padlock::Invitation]
  def self.issue(issuer:, confirmation_password:)
    invitation = new(
      issuer:,
      expires_at:,
      confirmation_password:,
      from_dangerous_action: true,
      unlocked_by: issuer
    )

    # Because issuing a new invitation has a non-zero chance of generating a non-unique token key, this loop is here as
    # a mitigation for these extreme edge case.
    until invitation.valid?
      break if invitation.errors.where(:key, :uniqueness).none?

      invitation.key = generate_unique_secure_token(length: KEY_LENGTH)
    end

    if invitation.save
      OnExpiredJob.set(wait_until: expires_at).perform_later(invitation)

      PendingChannel.broadcast_prepend_later_to(
        "invitations_pending",
        target: "pending-invitations",
        partial: "settings/invitations/invitation",
        locals: { invitation:, current_time: Time.current }
      )
    end

    invitation
  end

  def revoke(revoker:, confirmation_password:)
    fail NonRevocableError, "This invitation cannot be revoked because it does not have a carrier" unless carrier.present?

    carrier_to_expel = carrier
    revocation_outcome = false

    transaction do
      # We first nullify the carrier_id so we can protect the action with the confirmation password. This also allows us
      # to return early if before expeling the carrier from the platform.
      update!(
        unlocked_by: revoker,
        confirmation_password:,
        from_dangerous_action: true,
        carrier_id: nil,
      )

      carrier_to_expel.expel_from_party!

      destroy! # Now we can safely delete the record.

      revocation_outcome = true
    rescue StandardError => e
      Rails.logger.debug e.message
      Rails.logger.debug e.backtrace.join("\n")

      raise ActiveRecord::Rollback
    end

    if revocation_outcome
      # TODO: Handle character expulsion cases when it comes to UI updates.

      AcceptedChannel.broadcast_action_later_to(
        "invitations_accepted",
        action: :remove,
        targets: dom_id(self),
      )
    end

    revocation_outcome
  end

  def accept_character(attributes)
  end

  def accepted?
    carrier_id.present?
  end

  private

  def must_be_unlocked
    return if unlocked_by.present? && unlocked_by.password_padlock.unlock_for_dangerous_action(confirmation_password)

    errors.add(:confirmation_password, :invalid)
  end
end
