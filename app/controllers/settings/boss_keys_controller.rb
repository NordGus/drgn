class Settings::BossKeysController < SettingsController
  unlockable_with :locksmith_key

  require_unlocked_door

  requires_capability :manage

  before_action :set_adventurers
  before_action :set_adventurer, only: :show
  before_action :set_boss_key, only: :update

  def index
  end

  def show
  end

  def update
    respond_to do |format|
      if @boss_key.update_access(manager: Current.character, attributes: boss_key_params)
        @adventurer = @boss_key.holder.reload

        format.html { redirect_to settings_boss_key_path(id: @boss_key.holder_id), status: :see_other, notice: "Access updated." }
        format.json { head :no_content }
      else
        format.html { render :index, status: :unprocessable_entity, alert: "Access could not be updated." }
        format.json { render json: @boss_key.errors, status: :unprocessable_entity }
      end
    end
  end

  private

  def set_adventurers
    @adventurers = Character.includes(:boss_keys).active.is_adventurer.where.not(id: Current.character.id).order(created_at: :asc)
  end

  def set_adventurer
    @adventurer = @adventurers.find(params.expect(:id))
  end

  def set_boss_key
    @boss_key = BossKey.includes(holder: [ :boss_keys ]).active.where(holder: @adventurers).find(params.expect(:id))
  end

  def boss_key_params
    params.fetch(:boss_key, {}).permit(:confirmation_password, :access_level)
  end
end
