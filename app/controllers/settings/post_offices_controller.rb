class Settings::PostOfficesController < SettingsController
  unlockable_with :postmaster_key

  require_unlocked_door

  requires_capability :manage

  before_action :set_settings_post_office

  # GET /settings/post_office or /settings/post_office.json
  def show
  end

  # PATCH/PUT /settings/post_office or /settings/post_office.json
  def update
    respond_to do |format|
      if @settings_post_office.update(settings_post_office_params)
        format.html { redirect_to @settings_post_office, notice: "Post office was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @settings_post_office }
      else
        format.html { render :show, status: :unprocessable_content }
        format.json { render json: @settings_post_office.errors, status: :unprocessable_content }
      end
    end
  end

  # POST /settings/post_office/test_connection or /settings/post_office/send_test_email.json
  def test_connection
    # TODO: figure out how to implement the connection test

    respond_to do |format|
      format.html { redirect_to settings_post_office_path, notice: "Test email sent." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_settings_post_office
      @settings_post_office = Mechanic::PostOffice.instance!
    end

    # Only allow a list of trusted parameters through.
    def settings_post_office_params
      params.fetch(:settings_post_office, {})
    end
end
