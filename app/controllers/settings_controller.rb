class SettingsController < ApplicationController
  before_action :set_character

  layout "settings"

  private

  # We load the character here so all controllers under Settings can access it and check for authorization. This also
  # is used for eagerload al character required data for the settings pannel.
    def set_character
      @character = Character.includes(:password_padlock, :sessions).where(deleted_at: nil).find(Current.session.character_id)
    end
end
