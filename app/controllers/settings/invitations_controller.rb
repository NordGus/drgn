class Settings::InvitationsController < SettingsController
  # TODO: Add authorization with the master key system
  before_action :set_invitation, only: %i[ destroy ]
  before_action :set_invitations, only: %i[ index create ]

  # GET /settings/invitations or /settings/invitations.json
  def index
  end

  # POST /settings/invitations or /settings/invitations.json
  def create
    confirmation_password = invitation_params[:confirmation_password]
    @invitation = Padlock::Invitation.issue(issuer: @character, confirmation_password:)

    respond_to do |format|
      if @invitation.persisted?
        format.html { redirect_to settings_invitations_path, notice: "Invitation was successfully created." }
        format.json { render :show, status: :created, location: @invitation }
      else
        format.html { render :index, status: :unprocessable_entity }
        format.json { render json: @invitation.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /settings/invitations/1 or /settings/invitations/1.json
  def destroy
    @invitation.destroy!

    respond_to do |format|
      format.html { redirect_to settings_invitations_path, notice: "Invitation was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_invitation
      @invitation = Padlock::Invitation.includes(:issuer, :carrier).find(params.expect(:id))
    end

  # Only allow a list of trusted parameters through.
  def invitation_params
    params.fetch(:padlock_invitation, {}).permit(:confirmation_password)
    end

  def set_invitations
    @invitations = Padlock::Invitation.includes(:issuer, :carrier).all.order(created_at: :desc)
  end
end
