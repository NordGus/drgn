class Setting::Text < ApplicationRecord
  belongs_to :mechanic, polymorphic: true
end
