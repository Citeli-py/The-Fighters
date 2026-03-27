class Professor < ApplicationRecord
  self.table_name = "professores"

  belongs_to :user

  attr_accessor :user_email

  validates :nome, :cpf, presence: true
  validates :cpf, uniqueness: true

  def data_nascimento_formatada
    data_nascimento&.strftime("%d/%m/%Y")
  end
end
