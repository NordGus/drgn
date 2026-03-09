class Padlock::Invitation < ApplicationRecord
  # TODO: move these values into system configurations
  EXPIRES_IN_DAYS = 1.freeze

  has_secure_token :key, length: 64

  belongs_to :issuer, class_name: "Character", foreign_key: :issuer_id
  belongs_to :carrier, class_name: "Character", foreign_key: :carrier_id, optional: true

  validates :key, presence: true
  validates :expires_at, presence: true, comparison: { greater_than_or_equal_to: ->(_) { Time.current } }
  validates :carrier_id, uniqueness: true, if: -> { carrier_id.present? }

  scope :pending, -> { where(carrier_id: nil) }
  scope :accepted, -> { where.not(carrier_id: nil) }

  def self.expires_at
    # TODO: move this value into system configurations
    EXPIRES_IN_DAYS.days.from_now
  end

  def self.issue(issuer:)
    invitation = new(issuer:, expires_at:)

    create_outcome = invitation.save

    OnIssuedJob.perform_later(invitation, Time.current) if create_outcome

    invitation
  end

  def accept_character(attributes)
  end

  def accepted?
    carrier_id.present?
  end
end
