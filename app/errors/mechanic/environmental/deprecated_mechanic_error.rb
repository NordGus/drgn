# frozen_string_literal: true

class Mechanic::Environmental::DeprecatedMechanicError < StandardError
  # @param mechanic Mechanic::Environmental
  def initialize(mechanic)
    super("#{mechanic.class} is deprecated since: #{mechanic.deleted_at.to_fs(:iso8601)}")
  end
end
