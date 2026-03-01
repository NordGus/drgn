# Preview all emails at http://localhost:3000/rails/mailers/character_mailer
class CharacterMailerPreview < ActionMailer::Preview
  # Preview this email at http://localhost:3000/rails/mailers/character_mailer/sheet_updated
  def sheet_updated
    CharacterMailer.sheet_updated(Character.includes(:password_padlock).take)
  end
end
