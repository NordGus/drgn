class Mechanic::PostOffice::DisableConfigurationErrorsNotification < Setting::Bool
  validates :type, inclusion: { in: %w[Mechanic::PostOffice::DisableConfigurationErrorsNotification] }
  validates :value, inclusion: { in: [ true, false ] }
end
