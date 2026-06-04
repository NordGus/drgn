require "test_helper"

class BossKey::OnAccessUpdatedJobTest < ActiveJob::TestCase
  include ActionCable::TestHelper

  setup do
    @boss_key = boss_key_locksmiths(:zoro_locksmith_key)

    @luffy = character_dungeon_masters(:luffy)
    @nami = character_adventurers(:nami)
    @zoro = character_adventurers(:zoro)
  end

  test "does nothing when boss_key is blank" do
    assert_no_broadcasts(@luffy.to_gid_param) do
      assert_equal :no_invitation_received, BossKey::OnAccessUpdatedJob.perform_now(nil, updated_access_direction: :access_upgraded)
    end
  end

  test "does nothing when updated_access_direction is not given" do
    assert_no_broadcasts(@luffy.to_gid_param) do
      assert_equal :no_updated_access_direction_given, BossKey::OnAccessUpdatedJob.perform_now(@boss_key)
    end
  end

  test "does nothing when access level was not modified" do
    assert_no_broadcasts(@luffy.to_gid_param) do
      assert_equal :access_level_unmodified, BossKey::OnAccessUpdatedJob.perform_now(@boss_key, updated_access_direction: :access_level_unmodified)
    end
  end

  test "broadcasts all required updates when access is changed" do
    settings_refresh_stream = "settings:#{@boss_key.settings_controller_name}:#{@zoro.to_gid_param}"
    settings_nav_stream = "settings:#{@zoro.to_gid_param}"

    assert_broadcasts(settings_refresh_stream, 1) do
      assert_broadcasts(settings_nav_stream, 1) do
        assert_broadcasts(@luffy.to_gid_param, 1) do
          assert_broadcasts(@nami.to_gid_param, 1) do
            assert_equal :boss_key_processed, BossKey::OnAccessUpdatedJob.perform_now(@boss_key, updated_access_direction: :access_upgraded)
          end
        end
      end
    end
  end
end
