class Mechanic::PostOffice::Port < Setting::Int
  validates :type, inclusion: { in: %w[Mechanic::PostOffice::Port] }
  validates :value, presence: true, unless: :new_record?
end
