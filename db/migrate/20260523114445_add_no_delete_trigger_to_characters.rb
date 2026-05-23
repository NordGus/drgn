class AddNoDeleteTriggerToCharacters < ActiveRecord::Migration[8.1]
  def up
    execute <<~SQL
      CREATE TRIGGER block_character_deletion
      BEFORE DELETE ON characters
      BEGIN
        SELECT RAISE(ABORT, 'Deletes are strictly forbidden on the characters table.');
      END;
    SQL
  end

  def down
    execute <<~SQL
      DROP TRIGGER IF EXISTS block_character_deletion;
    SQL
  end
end
