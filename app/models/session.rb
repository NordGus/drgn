class Session < ApplicationRecord
  # TODO: move these values into system configurations
  SESSION_EXPIRATION_IN_DAYS = 7.freeze

  has_secure_token length: 64

  belongs_to :character, inverse_of: :sessions

  scope :perishable, -> { where.not(expires_at: nil) }
  scope :non_perishable, -> { where(expires_at: nil) }

  def perishable?
    expires_at.present?
  end

  def expired?
    return false unless perishable?

    expires_at < Time.current
  end

  def self.expires_in
    SESSION_EXPIRATION_IN_DAYS.days
  end
end
