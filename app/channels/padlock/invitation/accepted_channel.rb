class Padlock::Invitation::AcceptedChannel < ApplicationCable::Channel
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

  def subscription_allowed?
    connection.current_character.present?
  end
end
