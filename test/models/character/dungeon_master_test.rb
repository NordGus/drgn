require "test_helper"

class Character::DungeonMasterTest < ActiveSupport::TestCase
  class MarkedAsDeletedTest < self
    setup do
      @character = character_dungeon_masters(:luffy)
      @attributes = { confirmation_password: "password" }
    end

    test "cannot be marked as deleted" do
      assert_no_changes -> { @character.reload.deleted_at } do
        assert_not @character.mark_as_deleted(@attributes)
        assert_includes @character.errors[:deleted_at], "must be blank"
      end
    end
  end

  class UpdateTypeTest < self
    setup do
      @character = character_dungeon_masters(:luffy)
    end

    test "cannot change their type" do
      assert_no_changes -> { @character.reload.type } do
        assert_not @character.update(type: "Character::Adventurer")
        assert_includes @character.errors[:type], "is not included in the list"
      end
    end
  end

  class ExpelFromPartyTest < self
    setup do
      @character = character_dungeon_masters(:luffy)
    end

    test "cannot be expelled from the party" do
      assert_no_changes -> { @character.reload.deleted_at } do
        assert_raises ActiveRecord::RecordInvalid do
          @character.expel_from_party!
        end
      end
    end
  end
end