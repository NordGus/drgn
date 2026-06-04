class Settings::BossKeysController < SettingsController
  unlockable_with :locksmith_key

  require_unlocked_door

  requires_capability :manage

  before_action :set_boss_keys
  before_action :set_boss_key, only: :update

  def index
  end

  def update
    respond_to do |format|
      if @boss_key.update_access(manager: Current.character, attributes: boss_key_params)
        @adventurer = @boss_key.holder.reload

        format.html { redirect_to settings_boss_keys_path, status: :see_other, notice: "Access updated." }
        format.json { head :no_content }
      else
        format.html { render :index, status: :unprocessable_entity, alert: "Access could not be updated." }
        format.json { render json: @boss_key.errors, status: :unprocessable_entity }
      end
    end
  end

  private

  def set_boss_keys
    @boss_keys = BossKey.includes(:holder).modifiable.where.not(holder: { id: Current.character.id }).order(:holder_id)
  end

  def set_boss_key
    @boss_key = @boss_keys.find(params.expect(:id))
  end

  def boss_key_params
    params.fetch(:boss_key, {}).permit(:confirmation_password, :access_level)
  end
end
