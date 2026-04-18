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

  private

  def subscription_allowed?
    # The Character needs to be present, otherwise the user is not logged in
    return false unless connection.current_character.present?

    # Only characters who have BossKey::Recruiter with access
    ::BossKey::Recruiter.with_access.exists?(holder: connection.current_character)
  end
end
