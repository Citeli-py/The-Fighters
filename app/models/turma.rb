class Turma < ApplicationRecord
  belongs_to :modalidade

  has_many :turma_alunos, dependent: :destroy
  has_many :alunos, through: :turma_alunos

  has_many :horarios, dependent: :destroy
end
