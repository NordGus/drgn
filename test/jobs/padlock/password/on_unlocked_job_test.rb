require "test_helper"

class Padlock::Password::OnUnlockedJobTest < ActiveJob::TestCase
  include ActiveSupport::Testing::TimeHelpers

  setup { @padlock = padlock_passwords(:luffys_active_password) }

  class WithAnActivePadlock < Padlock::Password::OnUnlockedJobTest
    test "stores when the padlock was unlocked and by what action" do
      freeze_time do
        unlocked_by = :dangerous_action_authorization
        last_unlocked_at = Time.current

        perform_enqueued_jobs do
          Padlock::Password::OnUnlockedJob.perform_later(@padlock, unlocked_by, last_unlocked_at)
        end

        assert_equal unlocked_by, @padlock.reload.unlocked_by.to_sym
        assert_equal last_unlocked_at, @padlock.reload.last_unlocked_at
      end
    end
  end

  class WithAPreviousPadlock < Padlock::Password::OnUnlockedJobTest
    setup { @padlock = padlock_passwords(:luffys_previous_password) }

    test "does nothing" do
      assert_equal :inactive_padlock_received, Padlock::Password::OnUnlockedJob.perform_now(@padlock, :web_login, Time.current)
    end
  end

  class WithNoPadlock < Padlock::Password::OnUnlockedJobTest
    test "does nothing" do
      assert_equal :no_padlock_received, Padlock::Password::OnUnlockedJob.perform_now(nil, :web_login, Time.current)
    end
  end
end
