class Padlock::Invitation::InUseChannel < ApplicationCable::Channel
  extend Turbo::Streams::Broadcasts, Turbo::Streams::StreamName
  include Turbo::Streams::StreamName::ClassMethods

  def subscribed
    if (stream_name = verified_stream_name_from_params).present? && subscription_allowed?
      stream_from stream_name
    else
      reject
    end
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  def subscription_allowed?
    connection.current_character.present?
  end
end
