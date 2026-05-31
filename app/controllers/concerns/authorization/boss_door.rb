# frozen_string_literal: true

##
# Authorization::BossDoor is a concern that handles BossKey-based (feature-based) authorization for controllers that
# use it.
module Authorization::BossDoor
  extend ActiveSupport::Concern

  class_methods do
    def unlockable_with(key)
      @_boss_key = key
    end

    def require_unlocked_door(**options)
      key = @_boss_key

      before_action(**options) { redirect_to root_path unless Current.character.public_send(key)&.can_access? }
    end

    def requires_capability(capability, **options)
      key = @_boss_key

      before_action(**options) { redirect_to root_path unless Current.character.public_send(key)&.public_send(:"can_#{capability}?") }
    end
  end
end
