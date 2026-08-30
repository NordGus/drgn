class CreateLedgerAccounts < ActiveRecord::Migration[8.1]
  def change
    create_table :ledger_accounts do |t|
      t.string :type, null: false
      t.string :name, null: false
      t.belongs_to :parent, null: true, foreign_key: { to_table: :ledger_accounts }
      t.belongs_to :creator, null: false, foreign_key: { to_table: :characters }
      t.datetime :deleted_at

      t.timestamps
    end

    add_index :ledger_accounts, :type, name: :index_ledger_accounts_on_type
    add_index :ledger_accounts, :name, name: :index_ledger_accounts_on_name
    add_index :ledger_accounts, :deleted_at, name: :index_ledger_accounts_on_deleted_at
  end
end
