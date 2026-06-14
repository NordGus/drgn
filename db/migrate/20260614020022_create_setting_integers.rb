class CreateSettingIntegers < ActiveRecord::Migration[8.1]
  def change
    create_table :setting_integers do |t|
      t.string :type, null: false
      t.belongs_to :mechanic, polymorphic: true, null: false
      t.integer :value

      t.timestamps
    end

    add_index :setting_integers, :type, name: :index_setting_integers_on_type
  end
end
