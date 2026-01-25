class Padlock::Password < ApplicationRecord
  has_secure_password :key

  belongs_to :character

  enum :unlocked_by, {
    web_login: 0,
    dangerous_action_authorization: 1
  }, default: :web_login, prefix: true

  has_one :_replaced_padlock, class_name: "Padlock::Password", dependent: :destroy, foreign_key: :replacement_padlock_id
  belongs_to :_replacement_padlock, optional: true, class_name: "Padlock::Password", foreign_key: :replacement_padlock_id

  scope :active, -> { where(replacement_padlock_id: nil) }
  scope :replaced, -> { where.not(replacement_padlock_id: nil) }
end
