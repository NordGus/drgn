class AddCurrencyEnumToLedgerAccounts < ActiveRecord::Migration[8.1]
  def change
    add_column :ledger_accounts, :currency, :integer, null: false, default: 0
  end
end
