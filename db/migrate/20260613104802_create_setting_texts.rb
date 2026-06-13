class CreateSettingTexts < ActiveRecord::Migration[8.1]
  def change
    create_table :setting_texts do |t|
      t.string :type, null: false
      t.belongs_to :mechanic, polymorphic: true, null: false
      t.text :value, null: false

      t.timestamps
    end

    add_index :setting_texts, :type, name: :index_setting_texts_on_type
    add_index :setting_texts, [ :mechanic_type, :mechanic_type ], name: :index_setting_texts_on_mechanic
    add_index :setting_texts, [ :type, :mechanic_type, :mechanic_type ], name: :index_setting_texts_on_type_and_mechanic
  end
end
