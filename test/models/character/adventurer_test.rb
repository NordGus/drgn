require "test_helper"

class Character::AdventurerTest < ActiveSupport::TestCase
  class UpdateTypeTest < self
    setup do
      @character = character_adventurers(:zoro)
    end

    test "cannot change their type" do
      assert_no_changes -> { @character.reload.type } do
        assert_not @character.update(type: "Character::DungeonMaster")
        assert_includes @character.errors[:type], "is not included in the list"
      end
    end
  end
end
