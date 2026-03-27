json.extract! invitation, :key, :created_at, :updated_at
json.url settings_invitation_url(invitation, format: :json)
