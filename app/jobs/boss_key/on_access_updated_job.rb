class BossKey::OnAccessUpdatedJob < ApplicationJob
  queue_as :default

  limits_concurrency to: 1, key: ->(boss_key, **) { boss_key }, duration: 1.minute, group: "PadlockActions"

  # Just in case something goes wrong during development. If this is happening on a production deployment something has
  # gone catastrophically wrong
  retry_on ActionView::MissingTemplate, wait: 5.seconds, attempts: 10, report: true

  discard_on ActiveRecord::RecordNotFound

  def perform(boss_key, updated_access_direction: nil)
    return :no_invitation_received unless boss_key.present?
    return :no_updated_access_direction_given unless updated_access_direction.present?
    # If access_level remained undefined we can save the work.
    return :access_level_unmodified if updated_access_direction == :access_level_unmodified

    # We refresh the holder's client to rerender the view progress be damned if the character is inside such panel. We do
    # this first to forcefully remove the user from the settings pannel if they no longer have access to the panel; or
    # simply update the UI with the new access_level clearence.
    ApplicationCable::StreamsChannel.broadcast_refresh_to(
      :settings, boss_key.settings_controller_name, boss_key.holder
    )

    # We bradcast the holder's updated settings menu, because it could have changed. We do not need to worry about state
    # on the client side becase we have a Stimulus controller setup to handle that for us, settings_controller.js.
    # We do this afterward becuase in case the user in not in the same panel so they can the settings updated to reflect
    # theire access level.
    ApplicationCable::StreamsChannel.broadcast_replace_to(
      :settings, boss_key.holder,
      target: "settings_navigation",
      partial: "shared/settings_nav",
      locals: { current_character: boss_key.holder }
    )

    # We broadcast the update to all users connected to the BossKeyChannel so they get the updated key state on their UI.
    BossKeyChannel.broadcast_access_updated(boss_key)

    :boss_key_processed
  end
end
