##
# Mechanic::PostOfficeChannel is the ApplicationCable::StreamsChannel that controls all streams related to Mechanic::PostOffice
# singleton for real-time updates and asynchronous communications
class Mechanic::PostOfficeChannel < ApplicationCable::StreamsChannel
  # Broadcasts the required UI changes when the Mechanic::PostOffice settings have been changed to all characters connected
  # to the post office settings panel to reflect the new platform state.
  #
  # @note This method should be called from a background job because this action could become a performance bottleneck,
  #   if a deployment break the assumptions of our engineering tradeoff.
  #
  # @note Make sure the post_office have all its components initialized.
  #
  # @param post_office [Mechanic::PostOffice]
  def self.broadcast_updated(post_office)
    # Using the BossKey::Postmaster feature we just need to broadcast that the Mechanic::PostOffice settings have been
    # changed to the party members with access to the Post Office BossDoor.
    #
    # Because we are inside a background job, and because of our engineering tradeoff, this iteration does not represent
    # a performance problem.
    BossKey::Postmaster.with_whom_can_be_broadcasted.find_each do |key|
      # We prepend the new invitation to the pending_invitation list
      broadcast_action_to(
        key.holder,
        action: :replace,
        target: "post_office_settings",
        partial: "settings/post_offices/form",
        locals: { current_character: key.holder, post_office: }
      )
    end
  end

  private

  def character_can_tap_this_channel?
    verified_stream_name_from_params == connection.current_character.to_gid_param &&
      connection.current_character.postmaster_key.can_access?
  end
end
