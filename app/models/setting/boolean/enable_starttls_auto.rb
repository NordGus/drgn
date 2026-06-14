class Setting::Boolean::EnableStarttlsAuto < Setting::Boolean
  validates :type, inclusion: { in: %w[Setting::Enum::Authentication] }
  validates :mechanic_type, inclusion: { in: %w[Mechanic::Environmental::PostOffice] }
  validates :value, presence: true
end
