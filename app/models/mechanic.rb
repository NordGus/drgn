class Mechanic < ApplicationRecord
  validates :type, presence: true, uniqueness: true, inclusion: { in: %w[Mechanic::PostOffice] }

  default_scope { order(created_at: :desc) }

  def self.instance!
    first_or_create!
  end
end
