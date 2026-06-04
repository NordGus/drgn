##
# Padlock::InvitationChannel is the ApplicationCable::StreamsChannel that controls all streams related to Padlock::Invitation
# for real-time updates and asynchronous communications
class Padlock::InvitationChannel < ApplicationCable::StreamsChannel
  # Broadcasts the required UI changes when an invitation was issued to all characters connected to the invitations
  # settings panel to reflect the new platform state.
  #
  # @note This method should be called from a background job because this action could become a performance bottleneck,
  #   if a deployment break the assumptions of our engineering tradeoff.
  #
  # @param invitation [Padlock::Invitation]
  def self.broadcast_issued(invitation)
    # Using the BossKey::Recruiter feature we just need to broadcast that the invitation was issued to the party members
    # with access to the Invitations BossDoor.
    #
    # Because we are inside a background job, and because of our engineering tradeoff, this iteration does not represent
    # a performance problem.
    BossKey::Recruiter.with_whom_can_be_broadcasted.find_each do |key|
      # We prepend the new invitation to the pending_invitation list
      broadcast_action_to(
        key.holder,
        action: :prepend,
        target: "pending_invitations",
        partial: "settings/invitations/invitation",
        locals: { invitation:, current_time: Time.current, current_character: key.holder }
      )
    end
  end

  # Broadcasts the required UI changes when an invitation was claimed to all characters connected to the invitations
  # settings panel to reflect the new platform state.
  #
  # @note This method should be called from a background job because this action could become a performance bottleneck,
  #   if a deployment break the assumptions of our engineering tradeoff.
  #
  # @param invitation [Padlock::Invitation]
  def self.broadcast_claimed(invitation)
    # Using the BossKey::Recruiter feature we just need to broadcast that the invitation was claimed to the party members
    # with access to the Invitations BossDoor.
    #
    # Because we are inside a background job, and because of our engineering tradeoff, this iteration does not represent
    # a performance problem.
    BossKey::Recruiter.with_whom_can_be_broadcasted.find_each do |key|
      # We remove the invitation from the pending invitations list
      broadcast_remove_to(key.holder, target: invitation)

      # We prepend the claimed invitation to the accepted invitations list
      broadcast_action_to(
        key.holder,
        action: :prepend,
        target: "accepted_invitations",
        partial: "settings/invitations/invitation",
        locals: { invitation:, current_time: Time.current, current_character: key.holder }
      )
    end
  end

  # Broadcasts the required UI changes when an invitation was torn or revoked to all characters connected to the
  # invitations settings panel to reflect the new platform state.
  #
  # @note This method should be called from a background job because this action could become a performance bottleneck,
  #   if a deployment break the assumptions of our engineering tradeoff.
  #
  # @param invitation [Padlock::Invitation]
  def self.broadcast_torn_or_revoked(invitation)
    # Using the BossKey::Recruiter feature we just need to broadcast that the invitation was torn or revoked to the party
    # members with access to the Invitations BossDoor.
    #
    # Because we are inside a background job, and because of our engineering tradeoff, this iteration does not represent
    # a performance problem.
    BossKey::Recruiter.with_whom_can_be_broadcasted.find_each do |key|
      # We remove all ui elements related to the invitation
      broadcast_remove_to key.holder, targets: invitation
    end
  end

  # Broadcasts the updated invitation to all characters connected to the invitations settings panel to replace it with
  # the new invitation state.
  #
  # @note This method should be called from a background job because this action could become a performance bottleneck,
  #   if a deployment break the assumptions of our engineering tradeoff.
  #
  # @param invitation [Padlock::Invitation]
  def self.broadcast_holder_sheet_updated(invitation)
    # Using the BossKey::Recruiter feature we just need to broadcast that the invitation was claimed to the party members
    # with access to the Invitations BossDoor.
    #
    # Because we are inside a background job, and because of our engineering tradeoff, this iteration does not represent
    # a performance problem.
    BossKey::Recruiter.with_whom_can_be_broadcasted.find_each do |key|
      # We broadcast the updated invitation to holder in case is connected to the Invitations panel; and replace it
      # with the new invitation state.
      broadcast_replace_to(
        key.holder,
        target: invitation,
        partial: "settings/invitations/invitation",
        locals: { invitation:, current_time: Time.current, current_character: key.holder }
      )
    end
  end

  # Broadcasts the updated invitations to all characters connected to the invitations settings panel to replace it with
  # the new invitation state.
  #
  # @note This method should be called from a background job because this action could become a performance bottleneck,
  #   if a deployment break the assumptions of our engineering tradeoff.
  #
  # @param invitations [ActiveRecord::Relation<Padlock::Invitation>, Array<Padlock::Invitation>]
  def self.broadcast_issuer_sheet_updated(invitations)
    # Using the BossKey::Recruiter feature we just need to broadcast that the invitation was claimed to the party members
    # with access to the Invitations BossDoor.
    #
    # Because we are inside a background job, and because of our engineering tradeoff, this iteration does not represent
    # a performance problem.
    BossKey::Recruiter.with_whom_can_be_broadcasted.find_each do |key|
      # I know this is a performance nightmare, using nested loops, but is necessary to eat this somewhere. We use each
      # to mitigate the N+1 cases, becase the frist run should load into memory each record and reuse them there.
      invitations.each do |invitation|
        # We broadcast the updated invitation to holder in case is connected to the Invitations panel; and replace it
        # with the new invitation state.
        broadcast_replace_to(
          key.holder,
          target: invitation,
          partial: "settings/invitations/invitation",
          locals: { invitation:, current_time: Time.current, current_character: key.holder }
        )
      end
    end
  end

  private

  def character_can_tap_this_channel?
    verified_stream_name_from_params == connection.current_character.to_gid_param &&
      connection.current_character.recruiter_key.can_access?
  end
end
