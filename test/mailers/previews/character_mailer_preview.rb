# Preview all emails at http://localhost:3000/rails/mailers/character_mailer
class CharacterMailerPreview < ActionMailer::Preview
  # Preview this email at http://localhost:3000/rails/mailers/character_mailer/profile_updated
  def profile_updated
    CharacterMailer.profile_updated(Character.includes(:password_padlock).take)
  end
end
