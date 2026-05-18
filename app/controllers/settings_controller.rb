class SettingsController < ApplicationController
  # including Authorization::BossDoor to have settings-wide access to helper method :can_unlock_door? and also include
  # all authorization methods for controllers that use BossKey-based authorization to work, without needing to include
  # this concern on every single one of them.
  include Authorization::BossDoor

  before_action :set_character

  layout "settings"

  private

  # We load the character here so all controllers under Settings can access it and check for authorization. This also
  # is used for eagerload al character required data for the settings pannel.
  def set_character
    @character = Character.includes(
      :password_padlock,
      :sessions,
      :recruiter_key
    ).where(deleted_at: nil).find(Current.session.character_id)
  end

  def unprocessable_entity_response_with_custom_message(message)
    respond_to do |format|
      format.html do
        flash[:alert] = message

        render :index, status: :unprocessable_entity
      end

      format.json do
        errors = [ message ]

        render json: { errors: }, status: :unprocessable_entity
      end
    end
  end
end
