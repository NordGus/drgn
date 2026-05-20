##
# Padlock::InvitationChannel is the ApplicationCable::StreamsChannel that controls all streams related to Padlock::Invitation
# for real-time updates and asynchronous communications
class Padlock::InvitationChannel < Turbo::StreamsChannel
  def self.broadcast_claimed(invitation)
    BossKey::Recruiter.with_whom_can_be_broadcasted.find_each do |recruiter_key|
      broadcast_remove_to recruiter_key.holder, target: invitation

      broadcast_action_to(
        recruiter_key.holder,
        action: :prepend,
        target: "accepted_invitations",
        partial: "settings/invitations/invitation",
        locals: { invitation:, current_time: Time.current, current_character: recruiter_key.holder }
      )
    end
  end

  def self.broadcast_torn_or_revoked(invitation)
    BossKey::Recruiter.with_whom_can_be_broadcasted.find_each do |recruiter_key|
      broadcast_remove_to recruiter_key.holder, target: invitation
    end
  end

  private

  def character_can_tap_this_channel?
    connection.current_character.recruiter_key.can_access?
  end
end
