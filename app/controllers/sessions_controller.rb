class SessionsController < ApplicationController
  allow_unauthenticated_access only: %i[ new create ]
  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to new_session_path, alert: "Try again later." }

  def new
  end

  def create
    unlocked_padlock = Padlock::Password.unlock_padlock(username: params[:username], key: params[:password], by: :web_login)

    if (character = unlocked_padlock&.character)
      start_new_session_for character
      redirect_to after_authentication_url
    else
      redirect_to new_session_path, alert: "Try another username or password."
    end
  end

  def destroy
    terminate_session
    redirect_to new_session_path, status: :see_other, notice: "You have been logged out."
  end
end
