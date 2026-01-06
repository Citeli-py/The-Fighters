class CreatePresencas < ActiveRecord::Migration[8.1]
  def change
    create_table :presencas do |t|
      t.references :aluno, null: false, foreign_key: true
      t.references :aula, null: false, foreign_key: true
      t.boolean :presente

      t.timestamps
    end
  end
end
