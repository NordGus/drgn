class Mechanic::PostOffice::OnNotConfiguredJob < ApplicationJob
  queue_as :default

  def perform(current_time)
    return :no_notification_time_received unless current_time.present?

    post_office = Mechanic::PostOffice.instance!

    if post_office.disable_notifications&.value
      :notification_disabled
    else
      ScribingWindChannel.notify_postmasters_that_post_office_is_not_configured(current_time)

      :postmasters_notified
    end
  end
end
