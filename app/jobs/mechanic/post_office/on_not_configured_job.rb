class Mechanic::PostOffice::OnNotConfiguredJob < ApplicationJob
  queue_as :default

  limits_concurrency to: 1, key: :post_office, duration: 1.minute, group: "MechanicActions"

  # Just in case something goes wrong during development. If this is happening on a production deployment something has
  # gone catastrophically wrong
  retry_on ActionView::MissingTemplate, wait: 5.seconds, attempts: 10, report: true

  discard_on ActiveRecord::RecordNotFound

  def perform(current_time)
    return :no_notification_time_received unless current_time.present?

    post_office = Mechanic::PostOffice.instance!

    if post_office.disable_configuration_errors_notification&.value
      :notification_disabled
    else
      ScribingWindChannel.notify_postmasters_that_post_office_is_not_configured(current_time)

      :postmasters_notified
    end
  end
end
