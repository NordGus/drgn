class SettingsController < ApplicationController
  # including Authorization::BossDoor to have settings-wide access all authorization methods for controllers that use
  # BossKey-based authorization to work, without needing to include this concern on every single one of them.
  include Authorization::BossDoor

  layout "settings"

  private

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
