class Aluno < ApplicationRecord
  belongs_to :user, optional: true

  has_many :TurmaAluno, dependent: :destroy
  has_many :turmas, through: :TurmaAluno

  has_many :presencas, dependent: :destroy

  validates :nome, :data_nascimento, :cpf, presence: true


  def data_nascimento_formatada
    data_nascimento.strftime("%d/%m/%Y") if data_nascimento.present?
  end
end
