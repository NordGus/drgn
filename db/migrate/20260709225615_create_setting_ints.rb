class CreateSettingInts < ActiveRecord::Migration[8.1]
  def change
    create_table :setting_ints do |t|
      t.string :type, null: false, comment: "Contains the unique variable name of the setting"
      t.integer :value
      t.boolean :touched, null: false, default: false, comment: "Indicates if the setting has been touched by the user"
      t.belongs_to :mechanic, null: false, foreign_key: { to_table: :mechanics }, comment: "Mechanic to which the setting belongs to"

      t.timestamps
    end

    add_index :setting_ints, :type, unique: true, name: :uniqueness_setting_ints_on_type
    add_index :setting_ints, [ :type, :mechanic_id ], unique: true, name: :uniqueness_setting_ints_on_type_mechanic_id
  end
end
