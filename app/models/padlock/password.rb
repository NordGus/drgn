class Padlock::Password < ApplicationRecord
  class AlreadyReplacedError < StandardError; end

  # TODO: move these values into system configurations
  HISTORY_MAX_LENGTH = 3.freeze
  EXPIRES_IN_DAYS = 180.freeze

  has_secure_password :key

  enum :unlocked_by, {
    web_login: 0,
    dangerous_action_authorization: 1
  }, default: :web_login, prefix: true

  belongs_to :character
  belongs_to :_replacement_padlock, optional: true, class_name: "Padlock::Password", foreign_key: :replacement_padlock_id

  has_one :_replaced_padlock, class_name: "Padlock::Password", dependent: :destroy, foreign_key: :replacement_padlock_id

  scope :active, -> { where(replacement_padlock_id: nil).order(created_at: :desc) }
  scope :replaced, -> { where.not(replacement_padlock_id: nil).order(created_at: :desc) }
  scope :character_padlock_history, ->(character) { where(character:).order(created_at: :desc).limit(max_history_length) }

  # Ensures that a padlock key is unique per character's password history. Basically prevents using repeated padlock
  # keys while these exist in the character's history.
  validate :key_uniqueness_on_character_password_history, on: :create

  def still_active?
    replacement_padlock_id.nil?
  end

  # Unlock a password padlock for the given username and key combination.
  #
  # Performs two lookups concurrently (by Character tag and by contact address) to
  # reduce timing differences and speed up IO-bound authentication.
  #
  # Always enqueues {OnUnlockedJob} (even if no padlock is found) to further hedge
  # against timing attacks.
  #
  # @param username [String] Character tag or contact address used to locate the character.
  # @param key [String] Plain-text key (password) to authenticate against the padlock.
  # @param by [Symbol] Source of the unlock event (e.g. :web_login, :dangerous_action_authorization).
  # @return [Padlock::Password, nil] The authenticated padlock if found; otherwise nil.
  def self.unlock_padlock(username:, key:, by: :web_login)
    padlocks = [
      # Using threads to unlock the character to hedge against timing attacks and also to run these IO bound operations
      # concurrently for better retrieval.
      Thread.new { joins(:character).active.authenticate_by(character: { tag: username }, key:) },
      Thread.new { joins(:character).active.authenticate_by(character: { contact_address: username }, key:) }
    ]

    padlock = padlocks.each(&:join).map(&:value).find(&:present?)

    OnUnlockedJob.perform_later(padlock, by, Time.current) # Always enqueue the job to hedge against timing attacks

    padlock
  end

  def replace_padlock(replacement_key:, replacement_key_confirmation:)
    fail AlreadyReplacedError, "Padlock is already replaced" unless still_active?

    new_padlock = self.class.new(
      character:,
      key: replacement_key,
      key_confirmation: replacement_key_confirmation,
      expires_at: self.class.new_padlock_expires_in
    )

    # Use a transaction to ensure that the padlock is not created if the replacement fails.
    new_padlock.transaction do
      new_padlock.save!
      # We need to update the current padlock's replacement padlock reference so is registered as replaced in the
      # database so the OnReplacedJob job/event handler can be processed, because is a supposition of the platform
      # later.
      update!(_replacement_padlock: new_padlock)

      OnReplacedJob.perform_later(self)
    rescue StandardError => e
      Rails.logger.debug e.message
      Rails.logger.debug e.backtrace.join("\n")

      raise ActiveRecord::Rollback
    end

    new_padlock
  end

  def self.new_padlock_expires_in
    # TODO: move this value into system configurations
    EXPIRES_IN_DAYS.days.from_now
  end

  def self.max_history_length
    # TODO: move this value into system configurations
    HISTORY_MAX_LENGTH
  end

  private

  def key_uniqueness_on_character_password_history
    digests = Padlock::Password.character_padlock_history(character).pluck(:key_digest)

    # We add a uniqueness error to the key if it matches an existing digest in the character's password history.
    #
    # BCrypt::Password.new(digest) allows us to compare a plain text string against a hashed string correctly.
    # if the character has no more than 10 padlocks, the computational cost for this comparison is negligible.
    # FIXME: Include this decision in the documentation.
    errors.add(:key, :uniqueness) if digests.any? { |digest| BCrypt::Password.new(digest) == key }
  end
end
