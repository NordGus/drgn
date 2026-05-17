class RemoveOriginalTagFromCharacters < ActiveRecord::Migration[8.1]
  def change
    remove_column :characters, :original_tag, :string, limit: 4096, null: false
  end
end
