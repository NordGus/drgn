class Settings::CharactersController < SettingsController
  before_action :set_character, only: %i[ show update destroy ]

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
end
