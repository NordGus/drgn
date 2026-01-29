class PasswordsMailer < ApplicationMailer
  def reset(character)
    @character = character

    return unless @character.present?

    mail subject: "Reset your password", to: character.contact_address
  end
end
