class CreateLedgerMovements < ActiveRecord::Migration[8.1]
  def change
    create_table :ledger_movements do |t|
      t.string :type, null: false
      t.belongs_to :from, null: false, foreign_key: { to_table: :ledger_accounts }
      t.belongs_to :to, null: false, foreign_key: { to_table: :ledger_accounts }
      t.belongs_to :creator, null: false, foreign_key: { to_table: :characters }
      t.decimal :from_amount, null: false, precision: 16, scale: 4
      t.decimal :to_amount, null: false, precision: 16, scale: 4
      t.date :issued_at, null: false
      t.date :executed_at
      t.datetime :deleted_at

      t.timestamps
    end

    add_index :ledger_movements, :type, name: :index_ledger_movements_on_type
    add_index :ledger_movements, :issued_at, name: :index_ledger_movements_on_issued_at
    add_index :ledger_movements, :executed_at, name: :index_ledger_movements_on_executed_at
    add_index :ledger_movements, :deleted_at, name: :index_ledger_movements_on_deleted_at
  end
end
