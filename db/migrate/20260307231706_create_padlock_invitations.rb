class CreatePadlockInvitations < ActiveRecord::Migration[8.1]
  def change
    create_table :padlock_invitations do |t|
      t.belongs_to :issuer, null: false, foreign_key: { to_table: :characters }
      t.belongs_to :carrier, null: true, foreign_key: { to_table: :characters }
      t.string :key, null: false
      t.datetime :expires_at, null: false
      t.timestamp :last_unlocked_at

      t.timestamps
    end

    add_index :padlock_invitations, :key, unique: true
    add_index :padlock_invitations, :expires_at
    add_index :padlock_invitations, :carrier_id, unique: true, if_not_exists: true, where: "carrier_id IS NOT NULL"
  end
end
