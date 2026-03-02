class SettingsController < ApplicationController
  before_action :set_character

  layout "settings"

  private
    # We load the character here so all controllers under Settings can access it and check for authorization
    def set_character
      @character = Character.includes(:password_padlock, :sessions).where(deleted_at: nil).find(Current.character.id)
    end
end
