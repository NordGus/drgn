class CreateCharacters < ActiveRecord::Migration[8.1]
  def change
    create_table :characters, comment: "" do |t|
      t.string :type, null: false, default: "Character::Adventurer", comment: "Allows to register different types of characters"
      t.string :tag, null: false, limit: 4096
      t.string :contact_address, null: false, limit: 4096
      t.datetime :deleted_at

      t.timestamps
    end

    add_index :characters, :deleted_at, name: :index_characters_on_deleted_at
    add_index :characters, :tag, name: :index_characters_on_tag, unique: true
    add_index :characters, :contact_address, name: :index_characters_on_contact_address, unique: true
    add_index :characters, :type, name: :index_characters_on_type
    add_index :characters, :type, unique: true, where: "type = 'Character::DungeonMaster'", name: :index_characters_on_unique_dungeon_master
  end
end
