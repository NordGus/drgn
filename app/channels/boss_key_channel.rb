class BossKeyChannel < ApplicationCable::StreamsChannel
  # Using the BossKey::Locksmith feature we just need to broadcast that the boss_key was updated by on of the party
  # members with access to the Locksmith BossDoor.
  #
  # This action should be performed inside a background job, and because of our engineering tradeoff, this iteration
  # should not represent a performance problem.
  def self.broadcast_access_updated(boss_key)
    BossKey::Locksmith.with_whom_can_be_broadcasted.find_each do |key|
      # We replace the element with the stale state with one with the state fresh
      broadcast_replace_to(
        key.holder,
        target: boss_key,
        partial: "settings/boss_keys/boss_key",
        locals: { boss_key:, current_character: key.holder, current_time: Time.current }
      )
    end
  end

  private

  def character_can_tap_this_channel?
    connection.current_character.locksmith_key.can_access?
  end
end
