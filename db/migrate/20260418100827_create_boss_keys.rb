class CreateBossKeys < ActiveRecord::Migration[8.1]
  def change
    create_table :boss_keys do |t|
      t.string :type, null: false
      t.integer :access_level, null: false, default: 0
      t.belongs_to :holder, null: false, foreign_key: { to_table: :characters, name: :boss_keys_on_holder_fk }
      t.datetime :deleted_at

      t.timestamps
    end

    add_index :boss_keys, :type, name: :index_boss_keys_on_type
    add_index :boss_keys, :access_level, name: :index_boss_keys_on_access_level
    add_index :boss_keys, :deleted_at, name: :index_boss_keys_on_deleted_at
    add_index :boss_keys, [ :holder_id, :type ], unique: true, name: :index_boss_keys_on_holder_id_and_type
  end
end
