##
# Setting::Text is the parent model of all Mechanic's text-based settings or values that extend or set up a Mechanic.
# Do not use this model directly, use its subclasses instead.
# @note If you need a new setting, create a new subclass of this model.
class Setting::Text < ApplicationRecord
  belongs_to :mechanic

  validates :type, presence: true, uniqueness: true, exclusion: { in: %w[Setting::Text], message: "%{value} cannot use directly." }
  validates :touched, inclusion: { in: [ true, false ] }
end
