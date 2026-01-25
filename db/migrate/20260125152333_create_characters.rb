class CreateCharacters < ActiveRecord::Migration[8.1]
  def change
    create_table :characters do |t|
      t.string :tag, null: false
      t.datetime :deleted_at

      t.timestamps
    end

    add_index :characters, :deleted_at, name: :index_characters_on_deleted_at, if_not_exists: true
    add_index :characters, :tag, name: :index_characters_on_name, if_not_exists: true, unique: true
  end
end
