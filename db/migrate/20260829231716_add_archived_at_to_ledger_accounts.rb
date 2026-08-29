class AddArchivedAtToLedgerAccounts < ActiveRecord::Migration[8.1]
  def change
    add_column :ledger_accounts, :archived_at, :datetime

    add_index :ledger_accounts, :archived_at, name: :index_ledger_accounts_on_archived_at
  end
end
