class Session < ApplicationRecord
  has_secure_token length: 64

  belongs_to :character, inverse_of: :sessions
end
