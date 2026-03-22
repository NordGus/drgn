Rails.application.config.to_prepare do
  ActiveRecord::Type.register(:character, CharacterType)
end
