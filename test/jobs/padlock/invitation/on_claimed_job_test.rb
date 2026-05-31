require "test_helper"

class Padlock::Invitation::OnClaimedJobTest < ActiveJob::TestCase
  include ActionCable::TestHelper

  setup { @luffy = character_dungeon_masters(:luffy) }

  test "does nothing when not receiving an invitation" do
    assert_no_broadcasts(@luffy.to_gid_param) do
      assert_equal :no_invitation_received, Padlock::Invitation::OnClaimedJob.perform_now(nil)
    end
  end

  test "does nothing when the invitation has not accepted" do
    invitation = padlock_invitations(:pending_invitation)

    assert_no_broadcasts(@luffy.to_gid_param) do
      assert_equal :unclaimed_invitation_received, Padlock::Invitation::OnClaimedJob.perform_now(invitation)
    end
  end

  test "perform all background tasks required after issuing an invitation" do
    invitation = padlock_invitations(:zoro_invitation)

    assert_broadcasts(@luffy.to_gid_param, 2) do
      assert_equal :claimed_invitation_processed, Padlock::Invitation::OnClaimedJob.perform_now(invitation)
    end
  end
end
