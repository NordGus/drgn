class Mechanic::PostOffice::DisableNotification < Setting::Bool
  validates :type, inclusion: { in: %w[Mechanic::PostOffice::DisableNotification] }
  validates :value, inclusion: { in: [ true, false ] }
end
