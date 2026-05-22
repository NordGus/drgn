class AddDeletedAtToPadlockInvitations < ActiveRecord::Migration[8.1]
  def change
    add_column :padlock_invitations, :deleted_at, :datetime, null: true

    add_index :padlock_invitations, :deleted_at, name: :padlock_invitations_on_deleted_at_idx
  end
end
