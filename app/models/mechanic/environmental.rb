class Mechanic::Environmental < ApplicationRecord
  validates :type, presence: true, uniqueness: { scope: :deleted_at }

  scope :active, -> { where(deleted_at: nil) }

  def self.instance!
    mechanic = first || create_default_instance!

    fail DeprecatedMechanicError, mechanic if mechanic.deleted_at.present?

    mechanic
  end

  private

  def self.create_default_instance!
    fail NotImplementedError, "Mechanic::Environmental create_default_instance class method needs to be implemented in subclass"
  end
end
