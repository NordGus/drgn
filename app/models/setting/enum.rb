class Setting::Enum < Setting::Integer
  before_validation { self.value = 0 } # This enforces enum like behavior
end
