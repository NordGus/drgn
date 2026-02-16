class PasswordsMailer < ApplicationMailer
  def reset(character)
    @character = character

    mail subject: "Reset your password", to: character.contact_address
  end
end
