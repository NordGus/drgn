# frozen_string_literal: true

module TurboChargeable
  extend ActiveSupport::Concern

  included do
    extend Turbo::Streams::Broadcasts, Turbo::Streams::StreamName, Turbo::Streams::StreamName::ClassMethods
  end
end
