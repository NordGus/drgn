class Settings::CharactersController < SettingsController
  before_action :set_character, only: %i[ show update destroy ]

  # GET /character or /character.json
  def show
  end

  # PATCH/PUT /character or /character.json
  def update
    respond_to do |format|
      if @character.update(character_params)
        format.html { redirect_to settings_character_path, notice: "Character was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @character }
      else
        format.html { render :show, status: :unprocessable_entity }
        format.json { render json: @character.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /character or /character.json
  def destroy
    @character.destroy!

    respond_to do |format|
      format.html { redirect_to root_path, status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_character
      @character = Current.character
    end

    # Only allow a list of trusted parameters through.
    def character_params
      params.fetch(:character, {}).permit(:tag, :contact_address, :password)
    end
end
