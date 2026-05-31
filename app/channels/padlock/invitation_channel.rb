##
# Padlock::InvitationChannel is the ApplicationCable::StreamsChannel that controls all streams related to Padlock::Invitation
# for real-time updates and asynchronous communications
class Padlock::InvitationChannel < ApplicationCable::StreamsChannel
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
      # We broadcast the updated invitation to holder in case is connected to the Invitations panel; and replace it with
      # the new invitation state.
      broadcast_replace_to(
        key.holder,
        target: invitation,
        partial: "settings/invitations/invitation",
        locals: { invitation:, current_time: Time.current, current_character: key.holder }
      )
    end
  end

  private

  def character_can_tap_this_channel?
    connection.current_character.recruiter_key.can_access?
  end
end
