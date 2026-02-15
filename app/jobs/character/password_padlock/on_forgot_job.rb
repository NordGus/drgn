class Character::PasswordPadlock::OnForgotJob < ApplicationJob
  queue_as :default

  discard_on ActiveRecord::RecordNotFound

  def perform(username)
    return :no_username_received unless username.present?

    # We do not care about performance or hedging against timing attacks here, so we can use this "slow" approach.
    character = Character.includes(:password_padlock).find_by(tag: username) ||
                Character.includes(:password_padlock).find_by(contact_address: username)

    return :unknown_username unless character.present?

    PasswordsMailer.reset(character).deliver_later

    :instructions_sent
  end
end
