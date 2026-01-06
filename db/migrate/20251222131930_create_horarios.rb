class CreateHorarios < ActiveRecord::Migration[8.1]
  def change
    create_table :horarios do |t|
      t.references :turma, null: false, foreign_key: true
      t.integer :dia_semana
      t.time :hora_inicio
      t.time :hora_fim

      t.timestamps
    end
  end
end
