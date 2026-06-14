class Setting::Integer < ApplicationRecord
  belongs_to :mechanic, polymorphic: true

  validates :type, presence: true
end
