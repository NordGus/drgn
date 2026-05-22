##
# Padlock::InvitationChannel is the ApplicationCable::StreamsChannel that controls all streams related to Padlock::Invitation
# for real-time updates and asynchronous communications
class Padlock::InvitationChannel < Turbo::StreamsChannel
  private

  def character_can_tap_this_channel?
    connection.current_character.recruiter_key.can_access?
  end
end
