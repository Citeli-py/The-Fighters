class AddUniqueIndexToAulas < ActiveRecord::Migration[8.1]
  def change
    add_index :aulas, [ :horario_id, :data ], unique: true
  end
end
