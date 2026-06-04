require "test_helper"

class Padlock::InvitationChannelTest < ActionCable::Channel::TestCase
  class SubscribeTest < self
    test "confirms subscription when character has recruiter access" do
      character = character_adventurers(:nami)

      stub_connection current_character: character

      subscribe signed_stream_name: Padlock::InvitationChannel.signed_stream_name(character)

      assert subscription.confirmed?
      assert_has_stream character.to_gid_param
    end

    test "rejects subscription when character has no recruiter access" do
      character = character_adventurers(:zoro)

      stub_connection current_character: character

      subscribe signed_stream_name: Padlock::InvitationChannel.signed_stream_name(character)

      assert subscription.rejected?
      assert_has_no_stream character.to_gid_param
    end

    test "rejects subscription when subscribing to another character's stream" do
      character = character_adventurers(:nami)
      other_character = character_dungeon_masters(:luffy)

      stub_connection current_character: character

      subscribe signed_stream_name: Padlock::InvitationChannel.signed_stream_name(other_character)

      assert subscription.rejected?
      assert_has_no_stream other_character.to_gid_param
    end
  end

  class BroadcastIssuedTest < self
    setup do
      @invitation = padlock_invitations(:pending_invitation)
      @luffy = character_dungeon_masters(:luffy)
      @nami = character_adventurers(:nami)
      @kinemon = character_adventurers(:kinemon)
      @zoro = character_adventurers(:zoro)
    end

    test "broadcasts to all holders with recruiter access" do
      assert_broadcasts(@luffy.to_gid_param, 1) do
        assert_broadcasts(@nami.to_gid_param, 1) do
          assert_broadcasts(@kinemon.to_gid_param, 1) do
            Padlock::InvitationChannel.broadcast_issued(@invitation)
          end
        end
      end
    end

    test "does not broadcast to holders with no recruiter access" do
      assert_no_broadcasts(@zoro.to_gid_param) do
        Padlock::InvitationChannel.broadcast_issued(@invitation)
      end
    end
  end

  class BroadcastClaimedTest < self
    setup do
      @invitation = padlock_invitations(:zoro_invitation)
      @luffy = character_dungeon_masters(:luffy)
      @nami = character_adventurers(:nami)
      @kinemon = character_adventurers(:kinemon)
      @zoro = character_adventurers(:zoro)
    end

    test "broadcasts twice to all holders with recruiter access" do
      assert_broadcasts(@luffy.to_gid_param, 2) do
        assert_broadcasts(@nami.to_gid_param, 2) do
          assert_broadcasts(@kinemon.to_gid_param, 2) do
            Padlock::InvitationChannel.broadcast_claimed(@invitation)
          end
        end
      end
    end

    test "does not broadcast to holders with no recruiter access" do
      assert_no_broadcasts(@zoro.to_gid_param) do
        Padlock::InvitationChannel.broadcast_claimed(@invitation)
      end
    end
  end

  class BroadcastTornOrRevokedTest < self
    setup do
      @invitation = padlock_invitations(:zoro_invitation)
      @luffy = character_dungeon_masters(:luffy)
      @nami = character_adventurers(:nami)
      @kinemon = character_adventurers(:kinemon)
      @zoro = character_adventurers(:zoro)
    end

    test "broadcasts to all holders with recruiter access" do
      assert_broadcasts(@luffy.to_gid_param, 1) do
        assert_broadcasts(@nami.to_gid_param, 1) do
          assert_broadcasts(@kinemon.to_gid_param, 1) do
            Padlock::InvitationChannel.broadcast_torn_or_revoked(@invitation)
          end
        end
      end
    end

    test "does not broadcast to holders with no recruiter access" do
      assert_no_broadcasts(@zoro.to_gid_param) do
        Padlock::InvitationChannel.broadcast_torn_or_revoked(@invitation)
      end
    end
  end

  class BroadcastHolderSheetUpdatedTest < self
    setup do
      @invitation = padlock_invitations(:zoro_invitation)
      @luffy = character_dungeon_masters(:luffy)
      @nami = character_adventurers(:nami)
      @kinemon = character_adventurers(:kinemon)
      @zoro = character_adventurers(:zoro)
    end

    test "broadcasts once to all holders with recruiter access" do
      assert_broadcasts(@luffy.to_gid_param, 1) do
        assert_broadcasts(@nami.to_gid_param, 1) do
          assert_broadcasts(@kinemon.to_gid_param, 1) do
            Padlock::InvitationChannel.broadcast_holder_sheet_updated(@invitation)
          end
        end
      end
    end

    test "does not broadcast to holders with no recruiter access" do
      assert_no_broadcasts(@zoro.to_gid_param) do
        Padlock::InvitationChannel.broadcast_holder_sheet_updated(@invitation)
      end
    end
  end

  class BroadcastIssuerSheetUpdatedTest < self
    setup do
      @invitations = [ padlock_invitations(:zoro_invitation), padlock_invitations(:nami_invitation) ]
      @luffy = character_dungeon_masters(:luffy)
      @nami = character_adventurers(:nami)
      @kinemon = character_adventurers(:kinemon)
      @zoro = character_adventurers(:zoro)
    end

    test "broadcasts once per invitation to all holders with recruiter access" do
      assert_broadcasts(@luffy.to_gid_param, @invitations.size) do
        assert_broadcasts(@nami.to_gid_param, @invitations.size) do
          assert_broadcasts(@kinemon.to_gid_param, @invitations.size) do
            Padlock::InvitationChannel.broadcast_issuer_sheet_updated(@invitations)
          end
        end
      end
    end

    test "does not broadcast to holders with no recruiter access" do
      assert_no_broadcasts(@zoro.to_gid_param) do
        Padlock::InvitationChannel.broadcast_issuer_sheet_updated(@invitations)
      end
    end
  end
end