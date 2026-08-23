class AddOutflowsCountAndInflowsCountToLedgerAccounts < ActiveRecord::Migration[8.1]
  def change
    add_column :ledger_accounts, :outflows_count, :integer, default: 0, null: false
    add_column :ledger_accounts, :inflows_count, :integer, default: 0, null: false
  end
end
