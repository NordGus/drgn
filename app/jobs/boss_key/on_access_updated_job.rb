class BossKey::OnAccessUpdatedJob < ApplicationJob
  queue_as :default

  def perform(boss_key)
    # Do something later
  end
end
