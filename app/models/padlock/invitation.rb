class Padlock::Invitation < ApplicationRecord
  include PasswordLockable

  KEY_LENGTH = 64.freeze

  # TODO: move these values into system configurations
  EXPIRES_IN_DAYS = 1.freeze

  class StillAliveError < StandardError; end

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
