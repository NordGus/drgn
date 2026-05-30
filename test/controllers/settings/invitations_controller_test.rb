require "test_helper"

class Settings::InvitationsControllerTest < ActionDispatch::IntegrationTest
  class WithAnAuthorizedCharacter < self
    setup do
      @character = characters(:luffy)
      sign_in_as @character
    end

    test "should list all invitations" do
      get settings_invitations_url
      assert_response :success
    end

    test "should create invitation" do
      assert_difference -> { Padlock::Invitation.where(issuer: @character).count }, 1 do
        post settings_invitations_url, params: { padlock_invitation: { confirmation_password: "password" } }
      end

      assert_redirected_to settings_invitations_url
    end

    test "should not create an invitation when the confirmation password is invalid" do
      assert_no_difference -> { Padlock::Invitation.where(issuer: @character).count } do
        post settings_invitations_url, params: { padlock_invitation: { confirmation_password: "invalid_password" } }
      end

      assert_response :unprocessable_entity
    end

    test "should tear invitation" do
      invitation = padlock_invitations(:pending_invitation)

      assert_difference -> { Padlock::Invitation.active.count }, -1 do
        delete settings_invitation_url(invitation)
      end

      assert_redirected_to settings_invitations_url
    end

    test "should not tear invitation when it is already accepted" do
      invitation = padlock_invitations(:zoro_invitation)

      assert_no_difference -> { Padlock::Invitation.count } do
        delete settings_invitation_url(invitation)

        assert_response :unprocessable_entity
        assert_includes flash[:alert], "Invitation could not be tear because is already in use."
      end
    end

    test "should revoke invitation" do
      invitation = padlock_invitations(:zoro_invitation)
      holder = characters(:zoro)

      freeze_time do
        assert_changes -> { holder.reload.deleted_at }, from: nil, to: Time.current do
          assert_difference -> { Padlock::Invitation.active.count }, -1 do
            delete revoke_settings_invitation_url(invitation), params: { padlock_invitation: { confirmation_password: "password" } }

            assert_redirected_to settings_invitations_url
          end
        end
      end
    end

    test "should not revoke invitation when confirmation password is invalid" do
      invitation = padlock_invitations(:zoro_invitation)
      holder = characters(:zoro)

      assert_no_changes -> { holder.reload.deleted_at } do
        assert_no_difference -> { Padlock::Invitation.count } do
          delete revoke_settings_invitation_url(invitation), params: { padlock_invitation: { confirmation_password: "invalid_password" } }

          assert_response :unprocessable_entity
        end
      end
    end

    test "should not revoke a pending invitation" do
      invitation = padlock_invitations(:pending_invitation)

      assert_no_difference -> { Padlock::Invitation.count } do
        delete revoke_settings_invitation_url(invitation), params: { padlock_invitation: { confirmation_password: "password" } }

        assert_response :unprocessable_entity
        assert_includes flash[:alert], "Invitation could not be revoked is not in use."
      end
    end
  end

  class WithAnUnauthenticatedCharacter < self
    setup do
      @character = characters(:zoro)
      sign_in_as @character
    end

    test "should not list all invitations" do
      get settings_invitations_url

      assert_redirected_to root_url
    end

    test "should not create invitation" do
      assert_no_difference -> { Padlock::Invitation.where(issuer: @character).count } do
        post settings_invitations_url, params: { padlock_invitation: { confirmation_password: "password" } }
      end

      assert_redirected_to root_url
    end

    test "should not tear invitation" do
      invitation = padlock_invitations(:pending_invitation)

      assert_no_difference -> { Padlock::Invitation.count } do
        delete settings_invitation_url(invitation)
      end

      assert_redirected_to root_url
    end

    test "should not revoke invitation" do
      invitation = padlock_invitations(:zoro_invitation)
      holder = characters(:zoro)

      freeze_time do
        assert_no_changes -> { holder.reload.deleted_at } do
          assert_no_difference -> { Padlock::Invitation.count } do
            delete revoke_settings_invitation_url(invitation), params: { padlock_invitation: { confirmation_password: "password" } }

            assert_redirected_to root_url
          end
        end
      end
    end
  end
end
