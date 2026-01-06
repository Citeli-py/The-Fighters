class Modalidade < ApplicationRecord
  has_many :turmas, dependent: :destroy
end
