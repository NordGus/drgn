class Mechanic::PostOffice::Password < Setting::Text
  validates :type, inclusion: { in: %w[Mechanic::PostOffice::Password] }
  validates :value, presence: true, unless: :new_record?
end
