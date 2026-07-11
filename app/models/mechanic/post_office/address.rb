class Mechanic::PostOffice::Address < Setting::Text
  validates :type, inclusion: { in: %w[Mechanic::PostOffice::Address] }
  validates :value, presence: true, unless: :new_record?
end
