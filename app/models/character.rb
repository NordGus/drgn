class Character < ApplicationRecord
  normalizes :tag, with: ->(t) { t.strip.split(" ").reject(&:blank?).join(" ") }
  normalizes :contact_address, with: ->(t) { t.strip.downcase.strip.split(" ").reject(&:blank?).join("") }

  validates :tag, presence: true, uniqueness: true
  validates :contact_address, presence: true, uniqueness: true, email: true
  validates :deleted_at, comparison: { less_than_or_equal_to: Time.current }, if: :deleted_at

  encrypts :tag, deterministic: true, ignore_case: true
  encrypts :contact_address, deterministic: true, downcase: true

  has_many :sessions, inverse_of: :character, dependent: :destroy

  has_one :password_padlock, -> { active }, class_name: "Padlock::Password", foreign_key: :character_id, dependent: :destroy
  has_many :previous_password_padlocks, -> { replaced }, class_name: "Padlock::Password", foreign_key: :character_id, dependent: :destroy
end
