require "test_helper"

class PasswordsControllerTest < ActionDispatch::IntegrationTest
  setup { @character = characters(:luffy) }

  test "new" do
    get new_password_path
    assert_response :success
  end

  test "create" do
    post passwords_path, params: { username: @character.tag }

    assert_enqueued_email_with PasswordsMailer, :reset, args: [ @character ]

    assert_redirected_to new_session_path

    follow_redirect!
    assert_notice "reset instructions sent"
  end

  test "create for an unknown user redirects but sends no mail" do
    post passwords_path, params: { username: "missing-user@example.com" }

    assert_enqueued_emails 0

    assert_redirected_to new_session_path

    follow_redirect!
    assert_notice "reset instructions sent"
  end

  test "edit" do
    get edit_password_path(@character.password_padlock.key_reset_token)
    assert_response :success
  end

  test "edit with invalid password reset token" do
    get edit_password_path("invalid token")

    assert_redirected_to new_password_path

    follow_redirect!
    assert_notice "reset link is invalid"
  end

  test "update" do
    current_padlock = @character.password_padlock

    assert_changes -> { @character.reload.password_padlock.id } do
      assert_changes -> { current_padlock.reload.still_active? } do
        put password_path(@character.password_padlock.key_reset_token), params: { password: "new", password_confirmation: "new" }
        assert_redirected_to new_session_path
      end
    end

    follow_redirect!
    assert_notice "Password has been reset"
  end

  test "update with non matching passwords" do
    token = @character.password_padlock.key_reset_token

    assert_no_changes -> { @character.reload.password_padlock.id } do
      put password_path(token), params: { password: "no", password_confirmation: "match" }
      assert_redirected_to edit_password_path(token)
    end

    follow_redirect!
    assert_notice "Passwords did not match"
  end

  test "update with reused passwords" do
    token = @character.password_padlock.key_reset_token

    assert_no_changes -> { @character.reload.password_padlock.id } do
      put password_path(token), params: { password: "old_password_one", password_confirmation: "old_password_one" }
      assert_redirected_to edit_password_path(token)
    end

    follow_redirect!
    assert_notice "Your new password must be different from your previous passwords."
  end

  private
    def assert_notice(text)
      assert_select "div", /#{text}/
    end
end
