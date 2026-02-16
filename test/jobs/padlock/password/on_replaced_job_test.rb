require "test_helper"

class Padlock::Password::OnReplacedJobTest < ActiveJob::TestCase
  include ActiveJob::TestHelper

  test "when replacing a password which character that has an exhausted password history" do
    padlock = padlock_passwords(:luffys_previous_password)

    assert_difference -> { padlock.character.reload.previous_password_padlocks.count }, -5 do
      assert Padlock::Password::OnReplacedJob.perform_now(padlock)
    end
  end

  test "when replacing a password which character that does not have an exhausted password history" do
    padlock = padlock_passwords(:zoros_previous_password)

    assert_difference -> { padlock.character.reload.previous_password_padlocks.count }, 0 do
      assert_equal :history_has_not_been_exhausted, Padlock::Password::OnReplacedJob.perform_now(padlock)
    end
  end

  test "when no passing a password" do
    assert_difference -> { Padlock::Password.count }, 0 do
      assert_equal :no_padlock_received, Padlock::Password::OnReplacedJob.perform_now(nil)
    end
  end
end
