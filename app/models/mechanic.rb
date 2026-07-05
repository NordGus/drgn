class Mechanic < ApplicationRecord
  validates :type, presence: true, uniqueness: true, inclusion: { in: %w[Mechanic::PostOffice] }

  def self.instance!
    first_or_create!
  end
end
