class Modalidade < ApplicationRecord
  has_many :turmas, dependent: :destroy

  validates :nome, presence: true, uniqueness: { case_sensitive: false }
end
