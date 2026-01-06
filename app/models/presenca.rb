class Presenca < ApplicationRecord
  belongs_to :aluno
  belongs_to :aula

  validates :aluno_id, uniqueness: { scope: :aula_id }
end
