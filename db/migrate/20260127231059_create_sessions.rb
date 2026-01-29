class CreateSessions < ActiveRecord::Migration[8.1]
  def change
    create_table :sessions do |t|
      t.references :character, null: false, foreign_key: { to_table: :characters, name: :sessions_character_fk }
      t.string :ip_address
      t.string :user_agent
      t.string :token, null: false

      t.timestamps
    end

    add_index :sessions, :token, unique: true, name: :sessions_token
  end
end
