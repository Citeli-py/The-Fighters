class Horario < ApplicationRecord
  DIAS_SEMANA = {
    domingo: 0,
    segunda: 1,
    terca: 2,
    quarta: 3,
    quinta: 4,
    sexta: 5,
    sabado: 6
  }.freeze

  belongs_to :turma

  after_create_commit -> { AulasParaNovoHorarioJob.perform_later(id) }

  validates :dia_semana,
            presence: true,
            inclusion: { in: DIAS_SEMANA.values }


  def dia_semana_string
    DIAS_SEMANA.key(dia_semana)&.to_s&.humanize
  end
end
