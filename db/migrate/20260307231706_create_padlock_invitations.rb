class CreatePadlockInvitations < ActiveRecord::Migration[8.1]
  def change
    create_table :padlock_invitations do |t|
      t.belongs_to :issuer, null: false, foreign_key: { to_table: :characters }
      t.belongs_to :holder, null: true, foreign_key: { to_table: :characters }
      t.string :key, null: false
      t.datetime :expires_at, null: false
      t.datetime :last_unlocked_at
      t.datetime :deleted_at, null: true, default: nil

      t.timestamps
    end

    add_index :padlock_invitations, :key, unique: true, name: :index_padlock_invitations_on_unique_key
    add_index :padlock_invitations, :expires_at, name: :index_padlock_invitations_on_expires_at
    add_index :padlock_invitations, :holder_id, unique: true, where: "holder_id IS NOT NULL", name: :index_padlock_invitations_on_unique_holder
    add_index :padlock_invitations, :deleted_at, name: :index_padlock_invitations_on_deleted_at
  end
end
