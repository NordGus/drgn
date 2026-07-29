class Settings::PostOfficesController < SettingsController
  unlockable_with :postmaster_key

  require_unlocked_door

  requires_capability :manage

  before_action :set_settings_post_office
  before_action :initialize_missing_settings

  # GET /settings/post_office or /settings/post_office.json
  def show
  end

  # PATCH/PUT /settings/post_office or /settings/post_office.json
  def update
    if params[:test_connection]
      respond_to do |format|
        if @post_office.test_connection(post_office_params)
          flash.now[:notice] = "Connection succeed."

          format.turbo_stream do
            render turbo_stream: turbo_stream.update(
              "settings_content",
              html: render_to_string(:show, formats: [ :html ], layout: false)
            )
          end
          format.html { render :show, notice: "Connection succeed.", status: :ok }
          format.json { render :show, status: :ok, location: settings_post_office_path }
        else
          format.html { render :show, status: :unprocessable_entity }
          format.json { render json: @post_office.errors, status: :unprocessable_entity }
        end
      end
    else
      respond_to do |format|
        if @post_office.update_settings(post_office_params)
          format.html { redirect_to settings_post_office_path, notice: "Post office was successfully updated.", status: :see_other }
          format.json { render :show, status: :ok, location: settings_post_office_path }
        else
          format.html { render :show, status: :unprocessable_entity }
          format.json { render json: @post_office.errors, status: :unprocessable_entity }
        end
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_settings_post_office
      @post_office = Mechanic::PostOffice.instance!
    end

    def initialize_missing_settings
      @post_office.build_address unless @post_office.address.present?
      @post_office.build_port unless @post_office.port.present?
      @post_office.build_username unless @post_office.username.present?
      @post_office.build_password unless @post_office.password.present?
      @post_office.build_disable_configuration_errors_notification unless @post_office.disable_configuration_errors_notification.present?
    end

    # Only allow a list of trusted parameters through.
    def post_office_params
      params.require(:mechanic_post_office).permit(
        :confirmation_password,
        address_attributes: [ :id, :value ],
        port_attributes: [ :id, :value ],
        username_attributes: [ :id, :value ],
        password_attributes: [ :id, :value ],
        disable_configuration_errors_notification_attributes: [ :id, :value ]
      )
    end
end
