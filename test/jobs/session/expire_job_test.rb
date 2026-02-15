require "test_helper"

class Session::ExpireJobTest < ActiveJob::TestCase
  setup { @character = characters(:luffy) }

  test "with a non perishable session" do
    session =  @character.sessions.create!

    assert_difference -> { Session.count }, 0 do
      assert_equal :session_is_non_perishable, Session::ExpireJob.perform_now(session)
    end
  end

  test "with a non perishable session while forcing expiration" do
    session =  @character.sessions.create!

    assert_difference -> { @character.sessions.count }, -1 do
      assert_equal :session_expired, Session::ExpireJob.perform_now(session, force_expiration: true)
    end
  end

  test "with a perishable session which is still alive" do
    session = @character.sessions.create!(expires_at: 1.day.from_now)

    assert_difference -> { @character.sessions.count }, 0 do
      assert_equal :session_still_alive, Session::ExpireJob.perform_now(session)
    end
  end

  test "with a perishable session which has expired" do
    session = @character.sessions.create!(expires_at: 1.day.ago)

    travel_to 1.year.from_now do
      assert_difference -> { @character.sessions.count }, -1 do
        assert_equal :session_expired, Session::ExpireJob.perform_now(session)
      end
    end
  end

  test "with a perishable session which is still alive while forcing expiration" do
    session = @character.sessions.create!(expires_at: 1.day.from_now)

    assert_difference -> { @character.sessions.count }, -1 do
      assert_equal :session_expired, Session::ExpireJob.perform_now(session, force_expiration: true)
    end
  end
end
