require "test_helper"

class CharacterTest < ActiveSupport::TestCase
  setup { @character = characters(:luffy) }

  class WhenSettingUpdatedFromDangerousActionAttribute < self
    test "forces to pass the password padlock key to save the character" do
      @character.updated_from_dangerous_action = true
      @character.password = "password"

      assert @character.save
      assert_nil @character.reload.password
    end

    test "adds an error to the password attribute when it can't unlock password padlock" do
      @character.updated_from_dangerous_action = true
      @character.password = "invalid_password"

      assert_not @character.save
      assert_includes @character.errors[:password], "is invalid"
    end
  end

  class UpdateSheetTest < self
    setup do
      @character.sessions.create!

      @attributes = { tag: "king-luffy", password: "password" }
    end

    include ActiveJob::TestHelper

    test "needs to pass password padlock key to update character sheet" do
      assert_no_enqueued_jobs only: [ Character::OnSheetUpdatedJob ] do
        assert_no_changes -> { @character.reload.tag } do
          assert_no_difference -> { @character.sessions.count } do
            assert_not @character.update_sheet(@attributes.except(:password))
            assert_includes @character.errors[:password], "is invalid"
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
              assert_not_includes @character.errors[:password], "is invalid"
            end
          end
        end
      end
    end
  end

  class MarkedAsDeletedTest < self
    setup do
      @character.sessions.create!

      @attributes = { password: "password" }
    end

    include ActiveJob::TestHelper

    test "needs to pass password padlock key to mark character as deleted" do
      assert_no_enqueued_jobs only: [ Character::OnMarkedAsDeletedJob ] do
        assert_no_changes -> { @character.reload.deleted_at } do
          assert_no_difference -> { @character.sessions.count } do
            assert_not @character.mark_as_deleted(@attributes.except(:password))
            assert_includes @character.errors[:password], "is invalid"
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

              assert_not_includes @character.errors[:password], "is invalid"
            end
          end
        end
      end
    end
  end
end
