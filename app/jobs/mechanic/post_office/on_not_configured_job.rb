class Mechanic::PostOffice::OnNotConfiguredJob < ApplicationJob
  queue_as :default

  def perform(notification_time)
    return :no_notification_time_received unless notification_time.present?

    # We notify all postmasters that the post office is not configured.
    BossKey::Postmaster.with_whom_can_be_broadcasted.find_each do |key|
      ApplicationCable::StreamsChannel.broadcast_prepend_to(
        key.holder,
        target: "notifications",
        partial: "settings/post_offices/post_office_not_configured",
        locals: { current_time: Time.current, current_character: key.holder }
      )

      ApplicationCable::StreamsChannel.broadcast_prepend_to(
        :settings, key.holder,
        target: "notifications",
        partial: "settings/post_offices/post_office_not_configured",
        locals: { current_time: Time.current, current_character: key.holder }
      )
    end

    :postmasters_notified
  end
end
