json.extract! horario, :id, :turma_id, :dia_semana, :hora_inicio, :hora_fim, :created_at, :updated_at
json.url horario_url(horario, format: :json)
