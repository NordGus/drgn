class Settings::CharactersController < SettingsController
  before_action :set_character, only: %i[ show update replace_password destroy ]

  # GET /character or /character.json
  def show
  end

  # PATCH/PUT /character or /character.json
  def update
    respond_to do |format|
      if @character.update_sheet(character_params)
        format.html { redirect_to settings_character_path, notice: "Character sheet was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @character }
      else
        format.html { render :show, status: :unprocessable_entity }
        format.json { render json: @character.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /character/replace_password or /character/replace_password.json
  def replace_password
    replacement_key = replace_password_params[:password_padlock][:key]
    replacement_key_confirmation = replace_password_params[:password_padlock][:key_confirmation]
    confirmation_password = replace_password_params[:confirmation_password]

    respond_to do |format|
      if @character.password_padlock.replace_padlock(replacement_key:, replacement_key_confirmation:, confirmation_password:)
        format.html { redirect_to settings_character_path, notice: "Password Padlock was successfully replaced.", status: :see_other }
        format.json { render :show, status: :ok, location: @character }
      else
        format.html { render :show, status: :unprocessable_entity }
        format.json { render json: @character.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /character or /character.json
  def destroy
    respond_to do |format|
      if @character.mark_as_deleted(destroy_character_params)
        format.html { redirect_to root_path, status: :see_other }
        format.json { head :no_content }
      else
        format.html { render :show, status: :unprocessable_entity }
        format.json { render json: @character.errors, status: :unprocessable_entity }
      end
    end
  end

  private
    def set_character
      @character = Character.includes(:password_padlock, :sessions).where(deleted_at: nil).find(Current.character.id)
    end

    def character_params
      params.fetch(:character, {}).permit(:tag, :contact_address, :confirmation_password)
    end

    def destroy_character_params
      params.fetch(:character, {}).permit(:confirmation_password)
    end

    def replace_password_params
      params.fetch(:character, {}).permit(:confirmation_password, password_padlock: [ :key, :key_confirmation ])
    end
end
