class CreatePadlockPasswords < ActiveRecord::Migration[8.1]
  def change
    create_table :padlock_passwords do |t|
      t.belongs_to :character, null: false, type: :integer, foreign_key: { to_table: :characters, name: :padlock_passwords_on_replacement_padlock_fk }
      t.belongs_to :replacement_padlock, null: true, type: :integer, foreign_key: { to_table: :padlock_passwords, name: :padlock_passwords_on_replacement_padlock_fk }
      t.string :key_digest, null: false
      t.date :expires_at
      t.integer :unlocked_by, default: 0, null: false
      t.datetime :last_unlocked_at

      t.timestamps
    end
  end
end
