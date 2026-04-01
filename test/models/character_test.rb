require "test_helper"

class CharacterTest < ActiveSupport::TestCase
  setup { @character = characters(:luffy) }

  class UpdateSheetTest < self
    setup do
      @character.sessions.create!

      @attributes = { tag: "king-luffy", confirmation_password: "password" }
    end

    include ActiveJob::TestHelper

    test "needs to pass password padlock key to update character sheet" do
      assert_no_enqueued_jobs only: [ Character::OnSheetUpdatedJob ] do
        assert_no_changes -> { @character.reload.tag } do
          assert_no_difference -> { @character.sessions.count } do
            assert_not @character.update_sheet(@attributes.except(:confirmation_password))
            assert_includes @character.errors[:confirmation_password], "is invalid"
          end
        end
      end
    end

    test "enqueues a job to update the sheet" do
      freeze_time do
        assert_changes -> { @character.reload.tag } do
          assert_difference -> { @character.sessions.count }, -1 do
            assert_enqueued_with job: Character::OnSheetUpdatedJob, args: [ @character, Time.current ] do
              assert @character.update_sheet(@attributes)
              assert_not_includes @character.errors[:confirmation_password], "is invalid"
            end
          end
        end
      end
    end

    test "does nothing when attributes are not changed" do
      freeze_time do
        assert_no_changes -> { @character.reload.tag } do
          assert_no_difference -> { @character.sessions.count } do
            assert_no_enqueued_jobs do
              assert @character.update_sheet(@attributes.except(:tag))
              assert_empty @character.errors
            end
          end
        end
      end
    end
  end

  class MarkedAsDeletedTest < self
    setup do
      @character.sessions.create!

      @attributes = { confirmation_password: "password" }
    end

    include ActiveJob::TestHelper

    test "needs to pass password padlock key to mark character as deleted" do
      assert_no_enqueued_jobs only: [ Character::OnMarkedAsDeletedJob ] do
        assert_no_changes -> { @character.reload.deleted_at } do
          assert_no_difference -> { @character.sessions.count } do
            assert_not @character.mark_as_deleted(@attributes.except(:confirmation_password))
            assert_includes @character.errors[:confirmation_password], "is invalid"
          end
        end
      end
    end

    test "marks the character as deleted" do
      freeze_time do
        assert_changes -> { @character.reload.deleted_at }, from: nil, to: Time.current do
          assert_difference -> { @character.sessions.count }, -1 do
            assert_enqueued_with job: Character::OnMarkedAsDeletedJob, args: [ @character, Time.current ] do
              assert @character.mark_as_deleted(@attributes)

              assert_not_includes @character.errors[:confirmation_password], "is invalid"
            end
          end
        end
      end
    end
  end

  class ExpelFromPartyTest < self
    include ActiveJob::TestHelper

    # We create a session to test the application state changes as expected
    setup { @character.sessions.create! }

    test "expels the character from the party" do
      freeze_time do
        assert_changes -> { @character.reload.deleted_at }, from: nil, to: Time.current do
          assert_difference -> { @character.reload.sessions.count }, -1 do
            assert_enqueued_with(
              job: Character::OnMarkedAsDeletedJob,
              args: [@character, Time.current],
              at: ->(job_at) { (1.minute.from_now..3.minutes.from_now).cover?(job_at) }
            ) do
              assert @character.expel_from_party!
            end
          end
        end
      end
    end
  end
end
