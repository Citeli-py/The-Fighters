class Professor < ApplicationRecord
  belongs_to :user

  validates :nome, :cpf, presence: true
  validates :cpf, uniqueness: true

  def data_nascimento_formatada
    data_nascimento&.strftime("%d/%m/%Y")
  end
end
