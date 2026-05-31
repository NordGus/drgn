require "test_helper"

class Character::OnSheetUpdatedJobTest < ActiveJob::TestCase
  include ActionMailer::TestHelper
  include ActionCable::TestHelper

  setup do
    @character = character_dungeon_masters(:luffy)

    @luffy = character_dungeon_masters(:luffy)
    @nami = character_adventurers(:nami)
  end

  test "does nothing when not passing a character" do
    assert_enqueued_emails 0 do
      assert_no_broadcasts(@luffy.to_gid_param) do
        assert_no_broadcasts(@nami.to_gid_param) do
          assert_equal :no_character_received, Character::OnSheetUpdatedJob.perform_now(nil, Time.current)
        end
      end
    end
  end

  test "does nothing when last_updated_at is in the past" do
    assert_enqueued_emails 0 do
      assert_no_broadcasts(@luffy.to_gid_param) do
        assert_no_broadcasts(@nami.to_gid_param) do
          assert_equal :old_updated_at_timestamp_received, Character::OnSheetUpdatedJob.perform_now(@character, 1.year.ago)
        end
      end
    end
  end

  test "performs all post-sheet-update actions" do
    assert_enqueued_email_with CharacterMailer, :sheet_updated, args: [ @character ] do
      assert_broadcasts(@luffy.to_gid_param, 7) do
        assert_broadcasts(@nami.to_gid_param, 7) do
          assert_equal :post_sheet_actions_executed, Character::OnSheetUpdatedJob.perform_now(@character, Time.current)
        end
      end
    end
  end

  test "broadcasts the updated held invitation to connected invitation panel viewers" do
    character = character_adventurers(:zoro)

    assert_broadcasts(@luffy.to_gid_param, 5) do
      assert_broadcasts(@nami.to_gid_param, 5) do
        assert_equal :post_sheet_actions_executed, Character::OnSheetUpdatedJob.perform_now(character, Time.current)
      end
    end
  end
end
