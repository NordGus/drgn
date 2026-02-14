class Padlock::Password < ApplicationRecord
  has_secure_password :key

  belongs_to :character

  enum :unlocked_by, {
    web_login: 0,
    dangerous_action_authorization: 1
  }, default: :web_login, prefix: true

  has_one :_replaced_padlock, class_name: "Padlock::Password", dependent: :destroy, foreign_key: :replacement_padlock_id
  belongs_to :_replacement_padlock, optional: true, class_name: "Padlock::Password", foreign_key: :replacement_padlock_id

  scope :active, -> { where(replacement_padlock_id: nil).order(created_at: :desc) }
  scope :replaced, -> { where.not(replacement_padlock_id: nil).order(created_at: :desc) }

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
      Thread.new { Padlock::Password.joins(:character).active.authenticate_by(character: { tag: username }, key:) },
      Thread.new { Padlock::Password.joins(:character).active.authenticate_by(character: { contact_address: username }, key:) }
    ]

    padlock = padlocks.each(&:join).map(&:value).find(&:present?)

    OnUnlockedJob.perform_later(padlock, by, Time.current) # Always enqueue the job to hedge against timing attacks

    padlock
  end
end
