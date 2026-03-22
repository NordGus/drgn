class CharacterType < ActiveRecord::Type::Value
  def cast(value)
    if value.is_a?(Character)
      value
    elsif value.is_a?(String)
      Character.find_by(tag: value) || Character.find_by(contact_address: value)
    else
      Character.find_by(id: value)
    end
  end
end
