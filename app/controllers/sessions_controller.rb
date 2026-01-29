class SessionsController < ApplicationController
  allow_unauthenticated_access only: %i[ new create ]
  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to new_session_path, alert: "Try again later." }

  def new
  end

  def create
    unlocked_padlock = Padlock::Password.active.authenticate_by(character: { tag: params[:username] }, key: params[:password]) ||
                       Padlock::Password.active.authenticate_by(character: { contact_address: params[:username] }, key: params[:password])

    if unlocked_padlock
      start_new_session_for unlocked_padlock.character
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
