require "test_helper"

class Padlock::PasswordTest < ActiveSupport::TestCase
  class UnlockPadlockTest < Padlock::PasswordTest
    include ActiveJob::TestHelper

    class WithAnActivePadlockTest < UnlockPadlockTest
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

      class ByCharacterContactAddressTest < WithAnActivePadlockTest
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

    class WithAReplacedPadlockTest < UnlockPadlockTest
      setup { @padlock = padlock_passwords(:luffys_previous_password) }

      class ByCharacterTagTest < WithAnActivePadlockTest
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

      class ByCharacterContactAddressTest < WithAnActivePadlockTest
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

    class WithBadCredentialsTest < UnlockPadlockTest
      class WithInvalidUsernameTest < WithBadCredentialsTest
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

      class WithInvalidPassword < WithBadCredentialsTest
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
end
