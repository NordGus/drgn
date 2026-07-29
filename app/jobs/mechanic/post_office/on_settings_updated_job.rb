class Mechanic::PostOffice::OnSettingsUpdatedJob < ApplicationJob
  queue_as :default

  limits_concurrency to: 1, key: :post_office, duration: 1.minute, group: "MechanicActions"

  # Just in case something goes wrong during development. If this is happening on a production deployment something has
  # gone catastrophically wrong
  retry_on ActionView::MissingTemplate, wait: 5.seconds, attempts: 10, report: true

  discard_on ActiveRecord::RecordNotFound

  def perform(current_time)
    return :no_notification_time_received unless current_time.present?

    post_office = Mechanic::PostOffice.instance!

    # To prevent errors if a component is missing we need to initialize the missing components
    post_office.build_address unless post_office.address.present?
    post_office.build_port unless post_office.port.present?
    post_office.build_username unless post_office.username.present?
    post_office.build_password unless post_office.password.present?
    post_office.build_disable_notification unless post_office.disable_notification.present?

    # We broadcast the update to all party memebers connected to the settings panel
    Mechanic::PostOfficeChannel.broadcast_updated(post_office)

    # We notify all postmasters on the party that the smtp settings where changed on the platform
    ScribingWindChannel.notify_postmasters_that_post_office_settings_changed(post_office)

    # TODO: implement a mailer notification which is controlled by post_office.disable_notification

    :postmasters_notified_of_update
  end
end
