##
# Setting::Int is the parent model of all Mechanic's integer-based settings or values that extend or set up a Mechanic.
# It can also be used for integer-based ActiveRecord enums. Do not use this model directly, use its subclasses instead.
# @note If you need a new setting, create a new subclass of this model.
class Setting::Int < ApplicationRecord
  belongs_to :mechanic

  validates :type, presence: true, uniqueness: true, exclusion: { in: %w[Setting::Int], message: "%{value} cannot use directly." }
  validates :touched, inclusion: { in: [ true, false ] }
end
