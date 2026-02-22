require "test_helper"

class Character::OnSheetUpdatedJobTest < ActiveJob::TestCase
  include ActionMailer::TestHelper

  setup { @character = characters(:luffy) }

  test "does nothing when not passing a character" do
    assert_enqueued_emails 0 do
      assert_equal :no_character_received, Character::OnSheetUpdatedJob.perform_now(nil, Time.current)
    end
  end

  test "does nothing when last_updated_at is in the pass" do
    assert_enqueued_emails 0 do
      assert_equal :old_updated_at_timestamp_received, Character::OnSheetUpdatedJob.perform_now(@character, 1.year.ago)
    end
  end

  test "sends the email email notification communicating the update" do
    assert_enqueued_email_with CharacterMailer, :sheet_updated, args: [ @character ] do
      assert_equal :post_sheet_actions_executed, Character::OnSheetUpdatedJob.perform_now(@character, Time.current)
    end
  end
end
