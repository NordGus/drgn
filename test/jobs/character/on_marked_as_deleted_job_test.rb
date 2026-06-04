require "test_helper"

class Character::OnMarkedAsDeletedJobTest < ActiveJob::TestCase
  include ActionCable::TestHelper

  setup do
    @character = character_adventurers(:kanjuro)

    @character.sessions.create!(expires_at: 1.day.from_now)

    @luffy = character_dungeon_masters(:luffy)
    @nami = character_adventurers(:nami)
  end

  test "does nothing when not receiving a character" do
    assert_no_broadcasts(@character.to_gid_param) do
      assert_no_broadcasts(@luffy.to_gid_param) do
        assert_no_broadcasts(@nami.to_gid_param) do
          assert_no_changes -> { @character.reload.tag } do
            assert_no_changes -> { @character.reload.deleted_at } do
              assert_no_changes -> { @character.reload.contact_address } do
                assert_no_difference -> { @character.reload.sessions.count } do
                  assert_no_difference -> { @character.reload.boss_keys.count } do
                    assert_no_difference -> { Padlock::Password.where(character: @character).count } do
                      assert_equal :no_character_received, Character::OnMarkedAsDeletedJob.perform_now(nil, Time.current)
                    end
                  end
                end
              end
            end
          end
        end
      end
    end
  end

  test "does nothing when not receiving a deletion_timestamp" do
    assert_no_broadcasts(@character.to_gid_param) do
      assert_no_broadcasts(@luffy.to_gid_param) do
        assert_no_broadcasts(@nami.to_gid_param) do
          assert_no_changes -> { @character.reload.tag } do
            assert_no_changes -> { @character.reload.deleted_at } do
              assert_no_changes -> { @character.reload.contact_address } do
                assert_no_difference -> { @character.reload.sessions.count } do
                  assert_no_difference -> { @character.reload.boss_keys.count } do
                    assert_no_difference -> { Padlock::Password.where(character: @character).count } do
                      assert_equal :no_deletion_time_received, Character::OnMarkedAsDeletedJob.perform_now(@character, nil)
                    end
                  end
                end
              end
            end
          end
        end
      end
    end
  end

  test "does nothing when deletion_timestamp is in the past" do
    assert_no_broadcasts(@character.to_gid_param) do
      assert_no_broadcasts(@luffy.to_gid_param) do
        assert_no_broadcasts(@nami.to_gid_param) do
          assert_no_changes -> { @character.reload.tag } do
            assert_no_changes -> { @character.reload.deleted_at } do
              assert_no_changes -> { @character.reload.contact_address } do
                assert_no_difference -> { @character.reload.sessions.count } do
                  assert_no_difference -> { @character.reload.boss_keys.count } do
                    assert_no_difference -> { Padlock::Password.where(character: @character).count } do
                      assert_equal :old_deletion_timestamp_received, Character::OnMarkedAsDeletedJob.perform_now(@character, 1.hour.ago)
                    end
                  end
                end
              end
            end
          end
        end
      end
    end
  end

  test "does nothing when the character is not deleted" do
    character = character_adventurers(:zoro)

    assert_no_broadcasts(character.to_gid_param) do
      assert_no_broadcasts(@luffy.to_gid_param) do
        assert_no_broadcasts(@nami.to_gid_param) do
          assert_no_changes -> { character.reload.tag } do
            assert_equal :non_deleted_character_received, Character::OnMarkedAsDeletedJob.perform_now(character, character.updated_at)
          end
        end
      end
    end
  end

  test "removes all padlocks and wastes the tag and the contact address" do
    freeze_time do
      deletion_timestamp = @character.updated_at

      assert_broadcasts(@character.to_gid_param, 1) do
        assert_broadcasts(@luffy.to_gid_param, 2) do
          assert_broadcasts(@nami.to_gid_param, 2) do
            assert_broadcasts("settings:#{@character.to_gid_param}", 1) do
              assert_changes -> { @character.reload.tag } do
                assert_changes -> { @character.reload.contact_address } do
                  assert_difference -> { @character.reload.sessions.count }, -1 do
                    assert_difference -> { @character.reload.boss_keys.count }, -2 do
                      assert_difference -> { Padlock::Password.where(character: @character).count }, -1 do
                        assert_equal :character_deleted, Character::OnMarkedAsDeletedJob.perform_now(@character, deletion_timestamp)
                      end
                    end
                  end
                end
              end
            end
          end
        end
      end
    end
  end
end
