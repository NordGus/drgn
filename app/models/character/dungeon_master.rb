class Character::DungeonMaster < Character
  validates :type, presence: true, uniqueness: true, inclusion: { in: %w[Character::DungeonMaster] }
  validates :deleted_at, absence: true

  has_many :sessions, foreign_key: :character_id, dependent: :restrict_with_error

  has_one :password_padlock, -> { active }, class_name: "Padlock::Password", foreign_key: :character_id, dependent: :restrict_with_error
  has_many :previous_password_padlocks, -> { replaced }, class_name: "Padlock::Password", foreign_key: :character_id, dependent: :restrict_with_error

  has_many :issued_invitations, class_name: "Padlock::Invitation", foreign_key: :issuer_id, dependent: :restrict_with_error

  has_one :recruiter_key, class_name: "BossKey::Recruiter", foreign_key: :holder_id
  has_one :locksmith_key, class_name: "BossKey::Locksmith", foreign_key: :holder_id

  private

  def record_was_unlocked?
    password_padlock.unlock_for_dangerous_action(confirmation_password)
  end
end
