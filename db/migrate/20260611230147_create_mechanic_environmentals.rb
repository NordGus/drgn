class CreateMechanicEnvironmentals < ActiveRecord::Migration[8.1]
  def change
    create_table :mechanic_environmentals do |t|
      t.string :type, null: false
      t.datetime :deleted_at

      t.timestamps
    end

    add_index :mechanic_environmentals, :type, name: :index_mechanic_environmental_on_type
    add_index :mechanic_environmentals, :deleted_at, name: :index_mechanic_environmental_on_deleted_at
    add_index :mechanic_environmentals, [ :type, :deleted_at ], unique: true, name: :index_mechanic_environmental_on_type_and_deleted_at
  end
end
