class Mechanic::PostOffice::Username < Setting::Text
  validates :type, inclusion: { in: %w[Mechanic::PostOffice::Username] }
  validates :value, presence: true, unless: :new_record?
end
