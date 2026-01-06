class AulasService
  WINDOW_DAYS = 7

  def self.ensure_aulas_for_next_days(days = WINDOW_DAYS)
    start_date = Date.current
    end_date   = start_date + days.days

    turmas = Turma.includes(:horarios)

    aulas = []

    (start_date..end_date).each do |date|
      turmas.each do |turma|
        aulas += create_aulas_for_turma(turma, date)
      end
    end

    aulas
  end

  def self.create_aulas_for_turma(turma, date)
    aulas = []

    horarios = turma.horarios.where(dia_semana: date.wday)

    horarios.each do |horario|
      # 🔒 evita duplicidade
      next if Aula.exists?(horario: horario, data: date)

      aulas << Aula.create!(
        horario: horario,
        status: Aula::STATUS[:confirmada],
        data: date
      )
    end

    aulas
  end

  def self.update_past_aulas_status
    Aula
      .where("data < ?", Date.current)
      .where(status: Aula::STATUS[:confirmada])
      .find_each do |aula|
        aula.update_status(:realizada)
      end
  end
end
