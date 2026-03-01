require "test_helper"

class Character::OnMarkedAsDeletedJobTest < ActiveJob::TestCase
  setup do
    @character = characters(:luffy)

    @character.sessions.create!(expires_at: 1.day.from_now)
  end

  test "does nothing when not receiving a character" do
    assert_no_changes -> { @character.reload.tag } do
      assert_no_changes -> { @character.reload.deleted_at } do
        assert_no_changes -> { @character.reload.contact_address } do
          assert_no_difference -> { @character.reload.sessions.count } do
            assert_no_difference -> { Padlock::Password.where(character: @character).count } do
              assert_equal :no_character_received, Character::OnMarkedAsDeletedJob.perform_now(nil, Time.current)
            end
          end
        end
      end
    end
  end

  test "does nothing when not receiving a deletion_timestamp" do
    assert_no_changes -> { @character.reload.tag } do
      assert_no_changes -> { @character.reload.deleted_at } do
        assert_no_changes -> { @character.reload.contact_address } do
          assert_no_difference -> { @character.reload.sessions.count } do
            assert_no_difference -> { Padlock::Password.where(character: @character).count } do
              assert_equal :no_deletion_time_received, Character::OnMarkedAsDeletedJob.perform_now(@character, nil)
            end
          end
        end
      end
    end
  end

  test "does nothing when deletion_timestamp is in the past" do
    assert_no_changes -> { @character.reload.tag } do
      assert_no_changes -> { @character.reload.deleted_at } do
        assert_no_changes -> { @character.reload.contact_address } do
          assert_no_difference -> { @character.reload.sessions.count } do
            assert_no_difference -> { Padlock::Password.where(character: @character).count } do
              assert_equal :old_deletion_timestamp_received, Character::OnMarkedAsDeletedJob.perform_now(@character, 1.hour.ago)
            end
          end
        end
      end
    end
  end

  test "removes all padlocks and wastes the tag and the contact address" do
    freeze_time do
      deletion_timestamp = @character.updated_at

      assert_changes -> { @character.reload.tag } do
        assert_changes -> { @character.reload.deleted_at }, from: @character.deleted_at, to: deletion_timestamp do
          assert_changes -> { @character.reload.contact_address } do
            assert_difference -> { @character.reload.sessions.count }, -1 do
              assert_difference -> { Padlock::Password.where(character: @character).count }, -8 do
                assert_equal :character_deleted, Character::OnMarkedAsDeletedJob.perform_now(@character, deletion_timestamp)
              end
            end
          end
        end
      end
    end
  end
end
