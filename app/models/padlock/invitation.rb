class Padlock::Invitation < ApplicationRecord
  has_secure_token :key, length: 64

  belongs_to :issuer, class_name: "Character", foreign_key: :issuer_id
  belongs_to :carrier, class_name: "Character", foreign_key: :carrier_id, optional: true

  validates :key, presence: true
  validates :expires_at, presence: true, comparison: { greater_than_or_equal_to: ->(_) { Time.current } }
  validates :carrier_id, uniqueness: true, if: -> { carrier_id.present? }

  def accept_character(attributes)
  end
end
