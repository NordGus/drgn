require "test_helper"

class Padlock::Invitation::OnRevokedOrTornJobTest < ActiveJob::TestCase
  include ActionCable::TestHelper

  setup { @luffy = characters(:luffy) }

  test "does nothing when not receiving an invitation" do
    assert_no_changes -> { Padlock::Invitation.count } do
      assert_no_broadcasts(@luffy.to_gid_param) do
        assert_equal :no_invitation_received, Padlock::Invitation::OnRevokedOrTornJob.perform_now(nil)
      end
    end
  end

  test "does nothing when the invitation is accepted" do
    invitation = padlock_invitations(:zoro_invitation)

    assert_no_changes -> { Padlock::Invitation.count } do
      assert_no_broadcasts(@luffy.to_gid_param) do
        assert_equal :claimed_invitation_received, Padlock::Invitation::OnRevokedOrTornJob.perform_now(invitation)
      end
    end
  end

  test "does nothing when the invitation still active" do
    invitation = padlock_invitations(:pending_invitation)

    assert_no_changes -> { Padlock::Invitation.count } do
      assert_no_broadcasts(@luffy.to_gid_param) do
        assert_equal :non_deleted_invitation_received, Padlock::Invitation::OnRevokedOrTornJob.perform_now(invitation)
      end
    end
  end

  test "destroys the invitation and updates the ui" do
    invitation = padlock_invitations(:deleted_invitation)

    assert_changes -> { Padlock::Invitation.count }, -1 do
      assert_broadcasts(@luffy.to_gid_param, 1) do
        assert_equal :inactive_invitation_processed, Padlock::Invitation::OnRevokedOrTornJob.perform_now(invitation)
      end
    end
  end
end
