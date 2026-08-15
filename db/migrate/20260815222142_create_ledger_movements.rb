class CreateLedgerMovements < ActiveRecord::Migration[8.1]
  def change
    create_table :ledger_movements do |t|
      t.string :type, null: false
      t.belongs_to :source_account, null: false, foreign_key: { to_table: :ledger_accounts }
      t.belongs_to :destination_account, null: false, foreign_key: { to_table: :ledger_accounts }
      t.decimal :source_amount, precision: 16, scale: 2, null: false, default: 0.0
      t.decimal :destination_amount, precision: 16, scale: 2, null: false, default: 0.0
      t.date :issue_date, null: false
      t.date :execution_date

      t.timestamps
    end

    add_index :ledger_movements, :type, name: :index_ledger_movements_on_type
    add_index :ledger_movements, [ :type, :id ], name: :index_ledger_movements_on_type_and_id
    add_index :ledger_movements, :issue_date, name: :index_ledger_movements_on_issue_date
    add_index :ledger_movements, :execution_date, name: :index_ledger_movements_on_execution_date, where: "execution_date IS NOT NULL"
  end
end
