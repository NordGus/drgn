class Character::DungeonMaster < Character
  validates :type, presence: true, inclusion: { in: %w[Character::DungeonMaster] }

  # We reimplement expel_from_party! to prevent the DungeonMaster from been deleted
  def mark_as_deleted(attributes)
    # This error will prevent marking the DungeonMaster as deleted
    errors.add(:base, "The dungeon master cannot abdicate!")

    super attributes
  end

  # We reimplement expel_from_party! to prevent the DungeonMaster from been deleted
  def expel_from_party!
    errors.add(:base, "The dungeon master cannot abdicate!")

    super
  end
end
