class Setting::Text::UserName < Setting::Text
  validates :type, inclusion: { in: %w[Setting::Text::UserName] }
  validates :mechanic_type, inclusion: { in: %w[Mechanic::Environmental::PostOffice] }
  validates :value, presence: true, email: true
end
