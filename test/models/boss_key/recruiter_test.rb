require "test_helper"

class BossKey::RecruiterTest < ActiveSupport::TestCase
  class CanAccessTest < self
    test "returns true when key has share access" do
      assert boss_key_recruiters(:nami_recruiter_key).can_access?
    end

    test "returns true when key has invite access" do
      assert boss_key_recruiters(:kinemon_recruiter_key).can_access?
    end

    test "returns true when key has manage access" do
      assert boss_key_recruiters(:luffys_recruiter_key).can_access?
    end

    test "returns false when key has no access" do
      assert_not boss_key_recruiters(:zoro_recruiter_key).can_access?
    end

    test "returns false when key is deleted" do
      assert_not boss_key_recruiters(:kanjuro_recruiter_key).can_access?
    end
  end

  class CanShareTest < self
    test "returns true when key has share access" do
      assert boss_key_recruiters(:nami_recruiter_key).can_share?
    end

    test "returns true when key has invite access" do
      assert boss_key_recruiters(:kinemon_recruiter_key).can_share?
    end

    test "returns true when key has manage access" do
      assert boss_key_recruiters(:luffys_recruiter_key).can_share?
    end

    test "returns false when key has no access" do
      assert_not boss_key_recruiters(:zoro_recruiter_key).can_share?
    end
  end

  class CanInviteTest < self
    test "returns false when key only has share access" do
      assert_not boss_key_recruiters(:nami_recruiter_key).can_invite?
    end

    test "returns true when key has invite access" do
      assert boss_key_recruiters(:kinemon_recruiter_key).can_invite?
    end

    test "returns true when key has manage access" do
      assert boss_key_recruiters(:luffys_recruiter_key).can_invite?
    end

    test "returns false when key has no access" do
      assert_not boss_key_recruiters(:zoro_recruiter_key).can_invite?
    end
  end

  class CanRevokeTest < self
    test "returns false when key only has share access" do
      assert_not boss_key_recruiters(:nami_recruiter_key).can_revoke?
    end

    test "returns false when key only has invite access" do
      assert_not boss_key_recruiters(:kinemon_recruiter_key).can_revoke?
    end

    test "returns true when key has manage access" do
      assert boss_key_recruiters(:luffys_recruiter_key).can_revoke?
    end
  end

  class CanTeardownTest < self
    test "returns false when key only has share access" do
      assert_not boss_key_recruiters(:nami_recruiter_key).can_teardown?
    end

    test "returns false when key only has invite access" do
      assert_not boss_key_recruiters(:kinemon_recruiter_key).can_teardown?
    end

    test "returns true when key has manage access" do
      assert boss_key_recruiters(:luffys_recruiter_key).can_teardown?
    end
  end

  class SettingsControllerNameTest < self
    test "returns invitations" do
      assert_equal "invitations", boss_key_recruiters(:nami_recruiter_key).settings_controller_name
    end
  end

  class WithAccessScopeTest < self
    test "includes keys with share access that are not deleted" do
      assert_includes BossKey::Recruiter.with_access, boss_key_recruiters(:nami_recruiter_key)
    end

    test "includes keys with invite access that are not deleted" do
      assert_includes BossKey::Recruiter.with_access, boss_key_recruiters(:kinemon_recruiter_key)
    end

    test "includes keys with manage access that are not deleted" do
      assert_includes BossKey::Recruiter.with_access, boss_key_recruiters(:luffys_recruiter_key)
    end

    test "excludes keys with no access" do
      assert_not_includes BossKey::Recruiter.with_access, boss_key_recruiters(:zoro_recruiter_key)
    end

    test "excludes deleted keys" do
      assert_not_includes BossKey::Recruiter.with_access, boss_key_recruiters(:kanjuro_recruiter_key)
    end
  end
end
