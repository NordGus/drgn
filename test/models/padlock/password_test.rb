require "test_helper"

class Padlock::PasswordTest < ActiveSupport::TestCase
  class UnlockPadlockTest < self
    include ActiveJob::TestHelper

    class WithAnActivePadlockTest < self
      setup { @padlock = padlock_passwords(:luffys_active_password) }

      class ByCharacterTagTest < WithAnActivePadlockTest
        test "unlocks the padlock for the given character" do
          username = @padlock.character.tag
          key = "password"
          by = :dangerous_action_authorization

          freeze_time do
            assert_enqueued_with job: Padlock::Password::OnUnlockedJob, args: [ @padlock, by, Time.current ] do
              padlock = Padlock::Password.unlock_padlock(username:, key:, by:)

              assert_not_nil padlock
              assert_equal @padlock, padlock
              assert_equal @padlock.character, padlock&.character
            end
          end
        end
      end

      class ByCharacterContactAddressTest < self
        setup { @padlock = padlock_passwords(:zoros_active_password) }

        test "unlocks the padlock for the given character" do
          username = @padlock.character.contact_address
          key = "password"
          by = :dangerous_action_authorization

          freeze_time do
            assert_enqueued_with job: Padlock::Password::OnUnlockedJob, args: [ @padlock, by, Time.current ] do
              padlock = Padlock::Password.unlock_padlock(username:, key:, by:)

              assert_not_nil padlock
              assert_equal @padlock, padlock
              assert_equal @padlock.character, padlock&.character
            end
          end
        end
      end
    end

    class WithAReplacedPadlockTest < self
      setup { @padlock = padlock_passwords(:luffys_previous_password) }

      class ByCharacterTagTest < self
        test "unlocks the padlock for the given character" do
          username = @padlock.character.tag
          key = "old_password"
          by = :dangerous_action_authorization

          freeze_time do
            assert_enqueued_with job: Padlock::Password::OnUnlockedJob, args: [ nil, by, Time.current ] do
              padlock = Padlock::Password.unlock_padlock(username:, key:, by:)

              assert_nil padlock
            end
          end
        end
      end

      class ByCharacterContactAddressTest < self
        setup { @padlock = padlock_passwords(:zoros_previous_password) }

        test "unlocks the padlock for the given character" do
          username = @padlock.character.contact_address
          key = "old_password"
          by = :dangerous_action_authorization

          freeze_time do
            assert_enqueued_with job: Padlock::Password::OnUnlockedJob, args: [ nil, by, Time.current ] do
              padlock = Padlock::Password.unlock_padlock(username:, key:, by:)

              assert_nil padlock
            end
          end
        end
      end
    end

    class WithBadCredentialsTest < self
      class WithInvalidUsernameTest < self
        test "unlocks the padlock for the given character" do
          username = "invalid_username"
          key = "old_password"
          by = :dangerous_action_authorization

          freeze_time do
            assert_enqueued_with job: Padlock::Password::OnUnlockedJob, args: [ nil, by, Time.current ] do
              padlock = Padlock::Password.unlock_padlock(username:, key:, by:)

              assert_nil padlock
            end
          end
        end
      end

      class WithInvalidPassword < self
        setup { @padlock = padlock_passwords(:zoros_previous_password) }

        test "unlocks the padlock for the given character" do
          username = @padlock.character.contact_address
          key = "invalid_password"
          by = :dangerous_action_authorization

          freeze_time do
            assert_enqueued_with job: Padlock::Password::OnUnlockedJob, args: [ nil, by, Time.current ] do
              padlock = Padlock::Password.unlock_padlock(username:, key:, by:)

              assert_nil padlock
            end
          end
        end
      end
    end
  end

  class UnlockForDangerousActionTest < self
    include ActiveJob::TestHelper
    setup { @padlock = padlock_passwords(:luffys_active_password) }

    test "unlocks the padlock when the correct password is passed" do
      freeze_time do
        assert_enqueued_with job: Padlock::Password::OnUnlockedJob, args: [ @padlock, :dangerous_action_authorization, Time.current ] do
          assert @padlock.unlock_for_dangerous_action("password")
        end
      end
    end

    test "does not unlock the padlock when the wrong password is passed" do
      freeze_time do
        assert_no_enqueued_jobs do
          assert_not @padlock.unlock_for_dangerous_action("wrong_password")
        end
      end
    end

    test "does not unlock the padlock if it is not active" do
      padlock = padlock_passwords(:zoros_previous_password)

      freeze_time do
        assert_no_enqueued_jobs do
          assert_not padlock.unlock_for_dangerous_action("wrong_password")
        end
      end
    end
  end

  class ReplacePadlockTest < self
    include ActiveJob::TestHelper

    setup { @padlock = padlock_passwords(:luffys_active_password) }

    test "with valid keys" do
      freeze_time do
        replacement_key = "new_password"
        replacement_key_confirmation = "new_password"

        assert_difference -> { Padlock::Password.count }, 1 do
          assert_enqueued_with job: Padlock::Password::OnReplacedJob, args: [ @padlock ] do
            new_padlock = @padlock.replace_padlock(replacement_key:, replacement_key_confirmation:)

            assert new_padlock.persisted?
            assert_equal @padlock.replacement_padlock_id, new_padlock.id
            assert_equal Padlock::Password.new_padlock_expires_in.to_date, new_padlock.expires_at
            assert_equal @padlock.character_id, new_padlock.character_id
            assert_equal @padlock.character.password_padlock, new_padlock
            assert_equal replacement_key, new_padlock.key
            assert_equal replacement_key_confirmation, new_padlock.key_confirmation
          end
        end
      end
    end

    test "with no matching keys" do
      freeze_time do
        replacement_key = "new_password"
        replacement_key_confirmation = "new_password_no_match"

        assert_difference -> { Padlock::Password.count }, 0 do
          assert_no_enqueued_jobs do
            new_padlock = @padlock.replace_padlock(replacement_key:, replacement_key_confirmation:)

            assert_not new_padlock.persisted?
            assert_nil @padlock.reload.replacement_padlock_id
          end
        end
      end
    end

    test "with keys that exists in the characters password history" do
      freeze_time do
        replacement_key = "password"
        replacement_key_confirmation = "password"

        assert_difference -> { Padlock::Password.count }, 0 do
          assert_no_enqueued_jobs do
            new_padlock = @padlock.replace_padlock(replacement_key:, replacement_key_confirmation:)

            assert_not new_padlock.persisted?
            assert_nil @padlock.reload.replacement_padlock_id
          end
        end
      end
    end
  end
end
