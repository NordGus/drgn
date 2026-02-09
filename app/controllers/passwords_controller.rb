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
    if @padlock.update(params.permit(:key, :key_confirmation))
      @padlock.character.sessions.destroy_all
      redirect_to new_session_path, notice: "Password has been reset."
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
