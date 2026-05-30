class InvitationsController < ApplicationController
  allow_unauthenticated_access

  before_action :set_invitation, only: %i[ show claim ]
  rate_limit to: 10, within: 3.minutes, only: :claim, with: -> { redirect_to invitation_path(@invitation), alert: "Try again later." }

  rescue_from ActiveRecord::RecordNotFound, with: -> { redirect_to new_session_path }

  # GET /invitations/1 or /invitations/1.json
  def show
    @invitation.holder = Character.new
    @invitation.holder.password_padlock = Padlock::Password.new
  end

  # POST /invitations/1/claim or /invitations/1/claim.json
  def claim
    respond_to do |format|
      if @invitation.claim(character_creator_params)
        format.html { redirect_to new_session_path, notice: "Welcome to DRGN! Please, Sign In." }
        format.json { render :show, status: :created, location: @invitation }
      else
        format.html { render :show, status: :unprocessable_entity }
        format.json { render json: @invitation.errors, status: :unprocessable_entity }
      end
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_invitation
    @invitation = Padlock::Invitation.active.claimable.find_by!(key: params.expect(:key))
  end

  # Only allow a list of trusted parameters through.
  def character_creator_params
    params.fetch(:padlock_invitation, {}).permit(holder: [ :tag, :contact_address, password_padlock: [ :key, :key_confirmation ] ])
  end
end
