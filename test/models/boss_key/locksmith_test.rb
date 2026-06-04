require "test_helper"

class BossKey::LocksmithTest < ActiveSupport::TestCase
  class CanAccessTest < self
    test "returns true when key has manage access and is not deleted" do
      assert boss_key_locksmiths(:nami_locksmith_key).can_access?
    end

    test "returns false when key has no access" do
      assert_not boss_key_locksmiths(:zoro_locksmith_key).can_access?
    end

    test "returns false when key is deleted" do
      assert_not boss_key_locksmiths(:kanjuro_locksmith_key).can_access?
    end
  end

  class CanManageTest < self
    test "returns true when key has manage access" do
      assert boss_key_locksmiths(:nami_locksmith_key).can_manage?
    end

    test "returns false when key has no access" do
      assert_not boss_key_locksmiths(:zoro_locksmith_key).can_manage?
    end
  end

  class SettingsControllerNameTest < self
    test "returns boss_keys" do
      assert_equal "boss_keys", boss_key_locksmiths(:nami_locksmith_key).settings_controller_name
    end
  end

  class WithAccessScopeTest < self
    test "includes keys with manage access that are not deleted" do
      assert_includes BossKey::Locksmith.with_access, boss_key_locksmiths(:nami_locksmith_key)
    end

    test "excludes keys with no access" do
      assert_not_includes BossKey::Locksmith.with_access, boss_key_locksmiths(:zoro_locksmith_key)
    end

    test "excludes deleted keys even if they had access" do
      assert_not_includes BossKey::Locksmith.with_access, boss_key_locksmiths(:kanjuro_locksmith_key)
    end
  end
end
