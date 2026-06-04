require "test_helper"

class BossKeyTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  class UpdateAccessTest < self
    setup do
      @manager = character_adventurers(:nami)
      @key = boss_key_recruiters(:zoro_recruiter_key)
    end

    test "updates the access level when the manager's password is correct" do
      assert_changes -> { @key.reload.access_level }, from: "no", to: "share" do
        assert_enqueued_with(job: BossKey::OnAccessUpdatedJob, args: [ @key, { updated_access_direction: :access_upgraded } ]) do
          assert @key.update_access(manager: @manager, attributes: { access_level: :share, confirmation_password: "password" })
        end
      end
    end

    test "returns false and does not change access when the password is invalid" do
      assert_no_changes -> { @key.reload.access_level } do
        assert_no_enqueued_jobs(only: BossKey::OnAccessUpdatedJob) do
          assert_not @key.update_access(manager: @manager, attributes: { access_level: :share, confirmation_password: "wrong_password" })
        end
      end
    end

    test "returns false and does not change access for a dungeon master key" do
      key = boss_key_recruiters(:luffys_recruiter_key)

      assert_no_changes -> { key.reload.access_level } do
        assert_no_enqueued_jobs(only: BossKey::OnAccessUpdatedJob) do
          assert_not key.update_access(manager: @manager, attributes: { access_level: :no, confirmation_password: "password" })
        end
      end
    end
  end
end
