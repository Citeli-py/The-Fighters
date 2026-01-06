class CreateTurmas < ActiveRecord::Migration[8.1]
  def change
    create_table :turmas do |t|
      t.references :modalidade, null: false, foreign_key: true
      t.string :nome
      t.text :descricao

      t.timestamps
    end
  end
end
