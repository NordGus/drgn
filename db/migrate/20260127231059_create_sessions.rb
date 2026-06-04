class CreateSessions < ActiveRecord::Migration[8.1]
  def change
    create_table :sessions do |t|
      t.references :character, null: false, foreign_key: { to_table: :characters, name: :sessions_character_fk }
      t.string :ip_address
      t.string :user_agent
      t.datetime :expires_at, default: nil, comment: "Indicates when the session expires. This is used to store the"\
        " calculation of session expiration to save computation of retrieving session's life configuration from the"\
        " database and compare it with session's creation time in the controller authentication logic."
      t.string :token, null: false

      t.timestamps
    end

    add_index :sessions, :token, unique: true, name: :index_sessions_on_token
    add_index :sessions, :expires_at, name: :index_sessions_on_expires_at
  end
end
