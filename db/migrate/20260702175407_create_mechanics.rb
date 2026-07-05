class CreateMechanics < ActiveRecord::Migration[8.1]
  def change
    create_table :mechanics do |t|
      t.string :type, null: false

      t.timestamps
    end

    add_index :mechanics, :type, name: :index_mechanics_on_type, unique: true
  end
end
