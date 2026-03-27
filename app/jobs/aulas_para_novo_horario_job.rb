class AulasParaNovoHorarioJob < ApplicationJob
  queue_as :default

  def perform(horario_id)
    horario = Horario.find(horario_id)
    turma   = horario.turma

    start_date = Date.current
    end_date   = start_date + AulasService::WINDOW_DAYS.days

    (start_date..end_date).each do |date|
      next unless date.wday == horario.dia_semana
      next if Aula.exists?(horario: horario, data: date)

      Aula.create!(
        horario: horario,
        status: Aula::STATUS[:confirmada],
        data: date
      )
    end
  end
end
