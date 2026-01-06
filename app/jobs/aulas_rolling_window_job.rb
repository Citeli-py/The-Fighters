class AulasRollingWindowJob < ApplicationJob
  queue_as :default

  def perform(*args)
    AulasService.update_past_aulas_status
    AulasService.ensure_aulas_for_next_days()
  end
end
