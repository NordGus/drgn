class Character < ApplicationRecord
  normalizes :tag, with: ->(t) { t.strip.split(" ").reject(&:blank?).join(" ") }
  normalizes :contact_address, with: ->(t) { t.strip.downcase.strip.split(" ").reject(&:blank?).join("") }

  validates :tag, presence: true, uniqueness: true
  validates :contact_address, presence: true, uniqueness: true, email: true
  validates :deleted_at, comparison: { less_than_or_equal_to: Time.current }, if: :deleted_at
  # We validate that the password_padlock is unlocked only when is done from a dangerous action; otherwise it's unnecessary.
  validate :password_padlock_must_be_unlocked, if: -> { updated_from_dangerous_action }

  encrypts :tag, deterministic: true, ignore_case: true
  encrypts :contact_address, deterministic: true, downcase: true

  has_many :sessions, inverse_of: :character, dependent: :destroy

  has_one :password_padlock, -> { active }, class_name: "Padlock::Password", foreign_key: :character_id, dependent: :destroy
  has_many :previous_password_padlocks, -> { replaced }, class_name: "Padlock::Password", foreign_key: :character_id, dependent: :destroy

  attribute :password, :string, default: nil
  # This flag is used to control whether the character is updated from a dangerous action or not. This is used to control
  # the validation whether the character's password padlock is unlocked or not.
  attribute :updated_from_dangerous_action, :boolean, default: false

  def update_sheet(attributes)
    self.updated_from_dangerous_action = true

    update_outcome = update(attributes)

    OnSheetUpdatedJob.perform_later(self, Time.current) if update_outcome

    update_outcome
  end

  private

  def password_padlock_must_be_unlocked
    errors.add(:password, :invalid) unless password_padlock.unlock_for_dangerous_action(password)
  end
end
