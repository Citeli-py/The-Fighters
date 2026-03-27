class CreateProfessores < ActiveRecord::Migration[8.1]
  def change
    create_table :professores do |t|
      t.string  :nome,            null: false
      t.string  :cpf,             null: false
      t.date    :data_nascimento
      t.references :user,         null: false, foreign_key: true

      t.timestamps
    end

    add_index :professores, :cpf, unique: true
  end
end
