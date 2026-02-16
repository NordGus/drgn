require "test_helper"

class Session::Recurring::ExpireOrphanJobTest < ActiveJob::TestCase
  include ActiveJob::TestHelper

  setup do
    @character = characters(:luffy)
    @perishable_session = @character.sessions.create!(expires_at: 1.day.from_now)
    @non_perishable_session = @character.sessions.create!(expires_at: nil)
  end

  test "without forcing expiration" do
    assert_enqueued_jobs 1, only: Session::ExpireJob do
      assert_enqueued_with job: Session::ExpireJob, args: [ @perishable_session, { force_expiration: false } ] do
        assert_equal :only_perishable_sessions_expired, Session::Recurring::ExpireOrphanJob.perform_now
      end
    end
  end

  test "with forcing expiration" do
    assert_enqueued_jobs 2, only: Session::ExpireJob do
      assert_enqueued_with job: Session::ExpireJob, args: [ @perishable_session, { force_expiration: true } ] do
        assert_enqueued_with job: Session::ExpireJob, args: [ @non_perishable_session, { force_expiration: true } ] do
          assert_equal :all_sessions_expired, Session::Recurring::ExpireOrphanJob.perform_now(force_expiration: true)
        end
      end
    end
  end
end
