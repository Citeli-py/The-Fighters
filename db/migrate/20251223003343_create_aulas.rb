class CreateAulas < ActiveRecord::Migration[8.1]
  def change
    create_table :aulas do |t|
      t.string :code
      t.references :horario, null: false, foreign_key: true
      t.integer :status
      t.date :data

      t.timestamps
    end
  end
end
