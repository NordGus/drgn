class AddRoleToCharacters < ActiveRecord::Migration[8.1]
  def change
    add_column :characters, :role, :integer, null: false, default: 0

    add_index :characters, :role, name: :character_role_index
    add_index :characters, :role, unique: true, name: :dungeon_master_unique_role_constraint, where: "role = 9999",
              comment: "This constraint ensures that there is only one character that is the dungeon master of the "\
                "platform. This is an special role that other solutions may call superuser. So the role 9999 is "\
                "reserved for this special character."
  end
end
