class Setting::Integer::Timeout < Setting::Integer
  validates :type, inclusion: { in: %w[Setting::Integer::Port] }
  validates :mechanic_type, inclusion: { in: %w[Mechanic::Environmental::PostOffice] }
  validates :value, presence: true, numericality: { greater_than: 0 }
end
