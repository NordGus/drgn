class Character < ApplicationRecord
  validates :tag, presence: true, uniqueness: true
  validates :deleted_at, comparison: { less_than_or_equal_to: Time.current }, if: :deleted_at
end
