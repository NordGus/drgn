class Setting::Integer::Port < Setting::Integer
  validates :type, inclusion: { in: %w[Setting::Integer::Port] }
  validates :mechanic_type, inclusion: { in: %w[Mechanic::Environmental::PostOffice] }
  validates :value, presence: true, numericality: { greater_than_or_equal_to: 0 }
end
