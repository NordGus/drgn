class Padlock::Invitation < ApplicationRecord
  include PasswordLockable

  KEY_LENGTH = 64.freeze

  # TODO: move these values into system configurations
  EXPIRES_IN_DAYS = 1.freeze

  class StillAliveError < StandardError; end

  class NonRevocableError < StandardError; end

  class NonTearableError < StandardError; end

  class NonClaimableError < StandardError; end

  has_secure_token :key, length: KEY_LENGTH

  belongs_to :issuer, class_name: "Character", foreign_key: :issuer_id
  belongs_to :holder, class_name: "Character::Adventurer", foreign_key: :holder_id, optional: true

  validates :key, presence: true
  validates :issuer_id, presence: true
  validates :expires_at, presence: true, comparison: { greater_than_or_equal_to: -> { Time.current }, on: :create }
  validates :holder_id, uniqueness: true, if: -> { holder_id.present? }

  validates :deleted_at, presence: true, on: :destroy
  validates :holder_id, presence: false, on: :destroy

  scope :active, -> { where(deleted_at: nil) }
  scope :pending, -> { where(holder_id: nil) }
  scope :accepted, -> { where.not(holder_id: nil) }
  scope :claimable, -> { pending.where(expires_at: Time.current..) }
  scope :tearable, -> { pending.where(expires_at: ..Time.current) }

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
    # mitigation for these extreme edge case.
    until invitation.valid?
      break if invitation.errors.where(:key, :uniqueness).none?

      invitation.key = generate_unique_secure_token(length: KEY_LENGTH)
    end

    # if the invitation was issued we enqueue a job that perform all non-critical actions in the background so this action
    # is snappier for the issuer!
    OnIssuedJob.perform_later(invitation) if invitation.save

    invitation
  end

  # Claims the invitation by the given holder.
  #
  # @note This method has a self-contained transaction. So take this into consideration when calling it.
  #
  # @param character_creator_params [ActionController::Parameters] parameters for the holder creation.
  #
  # @return [Boolean] true if the invitation was successfully claimed, false otherwise.
  def claim(character_creator_params)
    fail NonClaimableError, "is claimed by another holder" if claimed?
    fail NonClaimableError, "has expired" if expired?

    claim_outcome = false

    transaction do
      self.holder = Character::Adventurer.new(character_creator_params.fetch(:holder, {}).permit(:tag, :contact_address))
      self.holder.password_padlock = Padlock::Password.new(character_creator_params.fetch(:holder, {}).fetch(:password_padlock, {}).permit(:key, :key_confirmation))
      self.holder.recruiter_key = BossKey::Recruiter.new(access_level: :no)
      self.holder.locksmith_key = BossKey::Locksmith.new(access_level: :no)

      self.holder.save!
      self.holder.password_padlock.save!
      self.holder.recruiter_key.save!
      self.holder.locksmith_key.save!

      update!(last_unlocked_at: Time.current)

      claim_outcome = true
    rescue StandardError => e
      Rails.logger.debug e.message
      Rails.logger.debug e.backtrace.join("\n")

      raise ActiveRecord::Rollback
    end

    # if the invitation was claimed we enqueue a job that perform all non-critical actions in the background so this action
    # is snappier for the claimer!
    OnClaimedJob.perform_later(self) if claim_outcome

    claim_outcome
  end

  def revoke(revoker:, confirmation_password:)
    fail NonRevocableError, "This invitation cannot be revoked because it does not has a holder" unless claimed?

    holder_to_expel = holder
    revocation_outcome = false

    transaction do
      # We first nullify the holder_id so we can protect the action with the confirmation password. This also allows us
      # to return early if before expeling the holder from the platform.
      update!(
        unlocked_by: revoker,
        confirmation_password:,
        from_dangerous_action: true,
        holder_id: nil,
        deleted_at: Time.current
      )

      holder_to_expel.expel_from_party!

      revocation_outcome = true
    rescue StandardError => e
      Rails.logger.debug e.message
      Rails.logger.debug e.backtrace.join("\n")

      raise ActiveRecord::Rollback
    end

    if revocation_outcome
      OnRevokedOrTornJob.perform_later(self)
    else # if revocation failed we need to
      self.holder_id = holder_to_expel.id

      errors.merge!(holder_to_expel.errors)
    end

    revocation_outcome
  end

  def tear
    fail NonTearableError, "This invitation cannot be torn because it has a holder" if claimed?

    tear_outcome = false

    transaction do
      update!(deleted_at: Time.current)

      tear_outcome = true
    rescue StandardError => e
      Rails.logger.debug e.message
      Rails.logger.debug e.backtrace.join("\n")

      raise ActiveRecord::Rollback
    end

    OnRevokedOrTornJob.perform_later(self) if tear_outcome

    tear_outcome
  end

  def claimed?
    holder_id.present?
  end

  def expired?
    expires_at < Time.current
  end

  def active?
    deleted_at.nil?
  end

  private

  def record_was_unlocked?
    unlocked_by.present? && unlocked_by.password_padlock.unlock_for_dangerous_action(confirmation_password)
  end
end
