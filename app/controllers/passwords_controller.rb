class PasswordsController < ApplicationController
  allow_unauthenticated_access
  before_action :set_padlock_by_token, only: %i[ edit update ]
  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to new_password_path, alert: "Try again later." }

  def new
  end

  def create
    characters = [
      Thread.new { Character.includes(:password_padlock).find_by(tag: params[:username]) },
      Thread.new { Character.includes(:password_padlock).find_by(contact_address: params[:username]) }
    ]

    if (character = characters.each(&:join).map(&:value).find(&:present?))
      PasswordsMailer.reset(character).deliver_later
    end

    redirect_to new_session_path, notice: "Password reset instructions sent (if user with that email address exists)."
  end

  def edit
  end

  def update
    replacement_key, replacement_key_confirmation = params.expect(:password, :password_confirmation)
    new_padlock = @padlock.replace_padlock(replacement_key:, replacement_key_confirmation:)

    if new_padlock.persisted?
      new_padlock.character.sessions.destroy_all
      redirect_to new_session_path, notice: "Password has been reset."
    elsif new_padlock.errors.where(:key, :uniqueness).any?
      redirect_to edit_password_path(params[:token]), alert: "Your new password must be different from your previous passwords."
    else
      redirect_to edit_password_path(params[:token]), alert: "Passwords did not match."
    end
  end

  private
    def set_padlock_by_token
      @padlock = Padlock::Password.includes(:character).active.find_by_key_reset_token!(params[:token])
    rescue ActiveSupport::MessageVerifier::InvalidSignature
      redirect_to new_password_path, alert: "Password reset link is invalid or has expired."
    end
end
