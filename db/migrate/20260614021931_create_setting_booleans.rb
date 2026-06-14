class CreateSettingBooleans < ActiveRecord::Migration[8.1]
  def change
    create_table :setting_booleans do |t|
      t.string :type, null: false
      t.belongs_to :mechanic, polymorphic: true, null: false
      t.boolean :value, null: false, default: false

      t.timestamps
    end

    add_index :setting_booleans, :type, name: :index_setting_booleans_on_type
  end
end
