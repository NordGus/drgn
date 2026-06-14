class Setting::Boolean < ApplicationRecord
  belongs_to :mechanic, polymorphic: true

  validates :type, presence: true
  validates :value, presence: true
end
