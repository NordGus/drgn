require "test_helper"

class BossKeyChannelTest < ActionCable::Channel::TestCase
  class SubscribeTest < self
    test "confirms subscription when character has locksmith access" do
      character = character_adventurers(:nami)

      stub_connection current_character: character

      subscribe signed_stream_name: BossKeyChannel.signed_stream_name(character)

      assert subscription.confirmed?
      assert_has_stream character.to_gid_param
    end

    test "rejects subscription when character has no locksmith access" do
      character = character_adventurers(:zoro)

      stub_connection current_character: character

      subscribe signed_stream_name: BossKeyChannel.signed_stream_name(character)

      assert subscription.rejected?
      assert_has_no_stream character.to_gid_param
    end

    test "rejects subscription when subscribing to another character's stream" do
      character = character_adventurers(:nami)
      other_character = character_dungeon_masters(:luffy)

      stub_connection current_character: character

      subscribe signed_stream_name: BossKeyChannel.signed_stream_name(other_character)

      assert subscription.rejected?
      assert_has_no_stream other_character.to_gid_param
    end
  end

  class BroadcastAccessUpdatedTest < self
    setup do
      @boss_key = boss_key_locksmiths(:zoro_locksmith_key)
      @luffy = character_dungeon_masters(:luffy)
      @nami = character_adventurers(:nami)
      @zoro = character_adventurers(:zoro)
    end

    test "broadcasts to all holders with locksmith access" do
      assert_broadcasts(@luffy.to_gid_param, 1) do
        assert_broadcasts(@nami.to_gid_param, 1) do
          BossKeyChannel.broadcast_access_updated(@boss_key)
        end
      end
    end

    test "does not broadcast to holders with no locksmith access" do
      assert_no_broadcasts(@zoro.to_gid_param) do
        BossKeyChannel.broadcast_access_updated(@boss_key)
      end
    end
  end

  class BroadcastHolderSheetUpdatedTest < self
    setup do
      @luffy = character_dungeon_masters(:luffy)
      @nami = character_adventurers(:nami)
      @zoro = character_adventurers(:zoro)

      @boss_keys = @zoro.boss_keys
    end

    test "broadcasts once per boss key to all holders with locksmith access" do
      assert_broadcasts(@luffy.to_gid_param, @boss_keys.size) do
        assert_broadcasts(@nami.to_gid_param, @boss_keys.size) do
          BossKeyChannel.broadcast_holder_sheet_updated(@boss_keys)
        end
      end
    end

    test "does not broadcast to holders with no locksmith access" do
      assert_no_broadcasts(@zoro.to_gid_param) do
        BossKeyChannel.broadcast_holder_sheet_updated(@boss_keys)
      end
    end
  end

  class BroadcastHolderMarkedAsDeletedTest < self
    setup do
      @luffy = character_dungeon_masters(:luffy)
      @nami = character_adventurers(:nami)
      @zoro = character_adventurers(:zoro)

      @boss_keys = @zoro.boss_keys
    end

    test "broadcasts once per boss key to all holders with locksmith access" do
      assert_broadcasts(@luffy.to_gid_param, @boss_keys.size) do
        assert_broadcasts(@nami.to_gid_param, @boss_keys.size) do
          BossKeyChannel.broadcast_holder_marked_as_deleted(@boss_keys)
        end
      end
    end

    test "does not broadcast to holders with no locksmith access" do
      assert_no_broadcasts(@zoro.to_gid_param) do
        BossKeyChannel.broadcast_holder_marked_as_deleted(@boss_keys)
      end
    end
  end
end
