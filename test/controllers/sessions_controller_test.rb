require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  include ActiveJob::TestHelper

  setup { @character = Character.includes(:password_padlock).take }

  test "new" do
    get new_session_path
    assert_response :success
  end

  test "create with valid credentials" do
    freeze_time do
      assert_enqueued_with job: Session::ExpireJob do
        post session_path, params: { username: @character.tag, password: "password", remember_me: "0" }

        session = Session.order(created_at: :desc).last

        assert_redirected_to root_path
        assert cookies[:session_id]
        assert_equal session.token, get_signed_cookie(:session_id)
        assert_equal Session.expires_in.from_now, session.expires_at
      end
    end
  end

  test "create with valid credentials while setting to remember de user" do
    freeze_time do
      assert_enqueued_with job: Session::ExpireJob do
        post session_path, params: { username: @character.tag, password: "password", remember_me: "1" }

        session = Session.order(created_at: :desc).last

        assert_redirected_to root_path
        assert cookies[:session_id]
        assert_equal session.token, get_signed_cookie(:session_id)
        assert_equal 1.year.from_now, session.expires_at
      end
    end
  end

  test "create with invalid credentials" do
    assert_no_enqueued_jobs only: Session::ExpireJob do
      post session_path, params: { username: @character.tag, password: "wrong", remember_me: "0" }

      assert_redirected_to new_session_path
      assert_nil cookies[:session_id]
    end
  end

  test "destroy" do
    sign_in_as(Character.includes(:password_padlock).take)

    delete session_path

    assert_redirected_to new_session_path
    assert_empty cookies[:session_id]
  end
end
