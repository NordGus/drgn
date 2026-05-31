class BossKeyChannel < ApplicationCable::StreamsChannel
  # Broadcasts the updated access to all characters connected to the locksmith settings panel to replace it with
  # the new boss key state.
  #
  # @note This method should be called from a background job because this action could become a performance bottleneck,
  #   if a deployment break the assumptions of our engineering tradeoff.
  #
  # @param boss_key [BossKey]
  def self.broadcast_access_updated(boss_key)
    # Using the BossKey::Locksmith feature we just need to broadcast that the boss_key was updated by on of the party
    # members with access to the Locksmith BossDoor.
    #
    # This action should be performed inside a background job, and because of our engineering tradeoff, this iteration
    # should not represent a performance problem.
    BossKey::Locksmith.with_whom_can_be_broadcasted.find_each do |key|
      # We replace the element with the stale state with one with the state fresh
      broadcast_replace_to(
        key.holder,
        target: boss_key,
        partial: "settings/boss_keys/form",
        locals: { boss_key: }
      )
    end
  end

  # Broadcasts the updated holder status to all characters connected to the locksmith settings panel to replace it with
  # the new boss key state.
  #
  # @note This method should be called from a background job because this action could become a performance bottleneck,
  #   if a deployment break the assumptions of our engineering tradeoff.
  #
  # @param boss_keys [ActiveRecord::Relation<BossKey>, Array<BossKey>]
  def self.broadcast_holder_sheet_updated(boss_keys)
    # Using the BossKey::Locksmith feature we just need to broadcast that the boss_key was updated by on of the party
    # members with access to the Locksmith BossDoor.
    #
    # This action should be performed inside a background job, and because of our engineering tradeoff, this iteration
    # should not represent a performance problem.
    BossKey::Locksmith.with_whom_can_be_broadcasted.find_each do |key|
      # I know this is a performance nightmare, using nested loops, but is necessary to eat this somewhere. We use each
      # to mitigate the N+1 cases, becase the frist run should load into memory each record and reuse them there.
      boss_keys.each do |boss_key|
        # We replace the element with the stale state with one with the state fresh
        broadcast_replace_to(
          key.holder,
          target: boss_key,
          partial: "settings/boss_keys/form",
          locals: { boss_key: }
        )
      end
    end
  end

  private

  def character_can_tap_this_channel?
    connection.current_character.locksmith_key.can_access?
  end
end
