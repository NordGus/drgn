require "test_helper"

class Character::PasswordPadlock::OnForgotJobTest < ActiveJob::TestCase
  include ActionMailer::TestHelper

  setup { @character = characters(:luffy) }

  test "with character tag as username" do
    assert_enqueued_email_with PasswordsMailer, :reset, args: [ @character ] do
      assert_equal :instructions_sent, Character::PasswordPadlock::OnForgotJob.perform_now(@character.tag)
    end
  end

  test "with character contact address as username" do
    assert_enqueued_email_with PasswordsMailer, :reset, args: [ @character ] do
      assert_equal :instructions_sent, Character::PasswordPadlock::OnForgotJob.perform_now(@character.contact_address)
    end
  end

  test "with unknown username" do
    assert_enqueued_emails 0 do
      assert_equal :unknown_username, Character::PasswordPadlock::OnForgotJob.perform_now("unknown_username")
    end
  end

  test "with nil username" do
    assert_enqueued_emails 0 do
      assert_equal :no_username_received, Character::PasswordPadlock::OnForgotJob.perform_now(nil)
    end
  end
end
