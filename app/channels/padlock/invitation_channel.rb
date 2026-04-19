class Padlock::InvitationChannel < ApplicationCable::Channel
  include TurboChargeable

  def subscribed
    if (stream_name = verified_stream_name_from_params).present? && subscription_allowed?
      stream_from stream_name
    else
      reject
    end
  end

  def unsubscribed
    super
  end

  def self.broadcast_issued(invitation)
    BossKey::Recruiter.with_whom_can_be_broadcasted.find_each do |recruiter_key|
      broadcast_action_to(
        recruiter_key.holder,
        action: :prepend,
        target: "pending_invitations",
        partial: "settings/invitations/invitation",
        locals: { invitation:, current_time: Time.current, current_character: recruiter_key.holder }
      )
    end
  end

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

  def subscription_allowed?
    # The Character needs to be present, otherwise the user is not logged in
    return false unless connection.current_character.present?

    # Only characters who have BossKey::Recruiter with access
    BossKey::Recruiter.with_access.exists?(holder: connection.current_character)
  end
end
