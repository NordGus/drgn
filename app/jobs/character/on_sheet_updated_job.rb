class Character::OnSheetUpdatedJob < ApplicationJob
  queue_as :default
  limits_concurrency to: 1, key: ->(character, *) { character }, duration: 1.minute, group: "CharacterActions"

  retry_on ActiveRecord::RecordNotSaved, ActiveRecord::RecordNotDestroyed, wait: 3.seconds, attempts: 3, report: true

  def perform(character, last_updated_at)
    return :no_character_received unless character.present?
    return :old_updated_at_timestamp_received if character.updated_at > last_updated_at

    # We send an email notification to the character to inform them of the chages
    CharacterMailer.sheet_updated(character).deliver_later
    Padlock::InvitationChannel.broadcast_holder_sheet_updated(character.invitation) if character.invitation.present?



    :post_sheet_actions_executed
  end
end
