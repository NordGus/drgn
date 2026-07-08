class ScribingWindChannel < ApplicationCable::StreamsChannel
  def self.notify_postmasters_that_post_office_is_not_configured(current_time)
    # We notify all postmasters that the post office is not configured.
    BossKey::Postmaster.with_whom_can_be_broadcasted.find_each do |key|
      # We prepend the notification to the notice board
      broadcast_prepend_to(
        key.holder,
        target: "notice_board",
        partial: "settings/post_offices/post_office_not_configured",
        locals: { current_time:, current_character: key.holder }
      )
    end
  end
end
