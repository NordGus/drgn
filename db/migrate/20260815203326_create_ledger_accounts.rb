class CreateLedgerAccounts < ActiveRecord::Migration[8.1]
  def change
    create_table :ledger_accounts do |t|
      t.string :type, null: false
      t.belongs_to :parent, null: true, foreign_key: { to_table: :ledger_accounts }
      t.string :name, null: false
      t.belongs_to :created_by, null: false, foreign_key: { to_table: :characters }

      t.timestamps
    end

    add_index :ledger_accounts, :type, name: :index_on_ledger_accounts_type
    add_index :ledger_accounts, [ :type, :id ], name: :index_on_ledger_accounts_type_and_id
    add_index :ledger_accounts, :name, name: :index_on_ledger_accounts_name
  end
end
