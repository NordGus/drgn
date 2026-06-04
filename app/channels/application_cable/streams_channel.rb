##
# ApplicationCable::StreamsChannel is custom implementation of Turbo::StreamsChannel with authorization built-in
# compatible with the platforms authentication for channels, that can be extended with authorization by its subclasses
# by overriding the character_can_tap_this_channel? method.
class ApplicationCable::StreamsChannel < ApplicationCable::Channel
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
    super
  end

  private

  def subscription_allowed?
    connection.current_character.present? && character_can_tap_this_channel?
  end

  def character_can_tap_this_channel?
    true
  end
end
