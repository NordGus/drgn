class Settings::InvitationsController < SettingsController
  before_action :only_allow_characters_with_access, only: :index
  before_action :only_allow_characters_that_can_invite, only: %i[ create ]
  before_action :only_allow_characters_that_can_revoke, only: %i[ revoke ]
  before_action :only_allow_characters_that_can_teardown, only: %i[ destroy ]

  before_action :set_invitation, only: %i[ revoke destroy ]
  before_action :set_invitations, only: %i[ index create revoke destroy ]

  rescue_from Padlock::Invitation::NonTearableError, with: -> { unprocessable_entity_response_with_custom_message "Invitation could not be tear because is already in use." }
  rescue_from Padlock::Invitation::NonRevocableError, with: -> { unprocessable_entity_response_with_custom_message "Invitation could not be revoked is not in use." }

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
    @invitation.tear!

    respond_to do |format|
      format.html { redirect_to settings_invitations_path, notice: "Invitation was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  # DELETE /settings/invitations/1/revoke or /settings/invitations/1/revoke.json
  def revoke
    confirmation_password = revoke_invitation_params[:confirmation_password]

    respond_to do |format|
      if @invitation.revoke(revoker: @character, confirmation_password:)
        format.html { redirect_to settings_invitations_path, notice: "Invitation was successfully revoked.", status: :see_other }
        format.json { head :no_content }
      else
        format.html { render :index, status: :unprocessable_entity, alert: "Invitation could not be revoked." }
        format.json { render json: @invitation.errors, status: :unprocessable_entity }
      end
    end
  end

  private

  def set_invitation
    @invitation = Padlock::Invitation.includes(:issuer, :carrier).find(params.expect(:id))
  end

  def invitation_params
    params.fetch(:padlock_invitation, {}).permit(:confirmation_password)
  end

  def revoke_invitation_params
    params.fetch(:padlock_invitation, {}).permit(:confirmation_password)
  end

  def set_invitations
    @invitations = Padlock::Invitation.includes(:issuer, :carrier).all.order(created_at: :desc)
  end

  def only_allow_characters_with_access
    redirect_to root_path unless @character.recruiter_key.has_access?
  end

  def only_allow_characters_that_can_invite
    redirect_to root_path unless @character.recruiter_key.can_invite?
  end

  def only_allow_characters_that_can_revoke
    redirect_to root_path unless @character.recruiter_key.can_revoke?
  end

  def only_allow_characters_that_can_teardown
    redirect_to root_path unless @character.recruiter_key.can_teardown?
  end
end
