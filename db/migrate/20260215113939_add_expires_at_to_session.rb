class AddExpiresAtToSession < ActiveRecord::Migration[8.1]
  def change
    add_column(
      :sessions,
      :expires_at,
      :datetime,
      default: nil,
      comment: "Indicates when the session expires. This is used to store the calculation of session expiration to save"\
        " computation of retrieving session's life configuration from the database and compare it with session's creation"\
        " time in the controller authentication logic."
    )

    add_index(
      :sessions,
      :expires_at,
      name: :index_sessions_on_expires_at,
      comment: "Index to filter sessions that never expire for recurring cleaning jobs"
    )
  end
end
