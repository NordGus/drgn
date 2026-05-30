class Character::Adventurer < Character
  validates :type, presence: true, inclusion: { in: %w[Character::Adventurer] }
end
