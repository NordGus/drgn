class CreateSettingTexts < ActiveRecord::Migration[8.1]
  def change
    create_table :setting_texts do |t|
      t.string :type, null: false
      t.belongs_to :mechanic, polymorphic: true, null: false
      t.text :value, null: false

      t.timestamps
    end

    add_index :setting_texts, :type, name: :index_setting_texts_on_type
  end
end
