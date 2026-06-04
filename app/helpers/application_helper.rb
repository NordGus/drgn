module ApplicationHelper
  # Used in the view to create a subscription to a stream identified by the <tt>streamables</tt> running over the
  # <tt>ApplicationCable::StreamsChannel</tt> that only authenticated users can connect to. The stream name being
  # generated is safe to embed in the HTML sent to a user without fear of tampering, as it is signed using
  # <tt>Turbo.signed_stream_verifier</tt>. Example:
  #
  #   # app/views/entries/index.html.erb
  #   <%= authorized_turbo_stream_from Current.account, :entries %>
  #   <div id="entries">New entries will be appended to this target</div>
  #
  # The example above will process all turbo streams sent to a stream name like <tt>account:5:entries</tt>
  # (when Current.account.id = 5). Updates to this stream can be sent like
  # <tt>entry.broadcast_append_to entry.account, :entries, target: "entries"</tt>.
  #
  # Custom channel class name can be passed using <tt>:channel</tt> option (either as a String
  # or a class name):
  #
  #   <%= authorized_turbo_stream_from "room", channel: RoomChannel %>
  #
  # It is also possible to pass additional parameters to the channel by passing them through `data` attributes:
  #
  #   <%= authorized_turbo_stream_from "room", channel: RoomChannel, data: {room_name: "room #1"} %>
  #
  # Raises an +ArgumentError+ if all streamables are blank
  #
  #   <%= authorized_turbo_stream_from("") %> # => ArgumentError: streamables can't be blank
  #   <%= authorized_turbo_stream_from("", nil) %> # => ArgumentError: streamables can't be blank
  def authorized_turbo_stream_from(*streamables, **attributes)
    attributes[:channel] = attributes[:channel]&.to_s || "ApplicationCable::StreamsChannel"

    turbo_stream_from(*streamables, **attributes)
  end
end
