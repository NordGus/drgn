class CharacterMailer < ApplicationMailer
  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.character_mailer.profile_updated.subject
  #
  def sheet_updated(character)
    @character = character

    mail subject: "Profile Updated", to: character.contact_address
  end
end
