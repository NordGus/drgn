class Setting::Text::Domain < Setting::Text
  validates :type, inclusion: { in: %w[Setting::Text::Domain] }
  validates :mechanic_type, inclusion: { in: %w[Mechanic::Environmental::PostOffice] }
  validates :value, presence: true
end
