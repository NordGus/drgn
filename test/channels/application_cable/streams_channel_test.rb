require "test_helper"

class ApplicationCable::StreamsChannelTest < ActionCable::Channel::TestCase
  class SubscribeTest < self
    test "confirms subscription when character is authenticated and stream name is valid" do
      character = character_adventurers(:nami)

      stub_connection current_character: character

      subscribe signed_stream_name: ApplicationCable::StreamsChannel.signed_stream_name(character)

      assert subscription.confirmed?
      assert_has_stream character.to_gid_param
    end

    test "rejects subscription when the stream name is invalid" do
      character = character_adventurers(:nami)

      stub_connection current_character: character

      subscribe signed_stream_name: "tampered_stream_name"

      assert subscription.rejected?
    end

    test "rejects subscription when character is not authenticated" do
      character = character_adventurers(:nami)

      stub_connection current_character: nil

      subscribe signed_stream_name: ApplicationCable::StreamsChannel.signed_stream_name(character)

      assert subscription.rejected?
    end
  end
end
