class AddUserIdToAlunos < ActiveRecord::Migration[8.1]
  def change
    add_reference :alunos, :user, null: true, foreign_key: true
  end
end
