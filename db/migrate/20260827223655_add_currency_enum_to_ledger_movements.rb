class AddCurrencyEnumToLedgerMovements < ActiveRecord::Migration[8.1]
  def change
    add_column :ledger_movements, :currency, :integer, null: false, default: 0
  end
end
