class PresencasController < ApplicationController
  before_action :set_aula, only: %i[ create destroy ]

  def create
    @presenca = @aula.presencas.build(aluno_id: params[:aluno_id])

    if @presenca.save
      redirect_to @aula,
        notice: "Presença registrada.",
        status: :see_other
    else
      redirect_to @aula,
        alert: @presenca.errors.full_messages.to_sentence,
        status: :unprocessable_entity
    end
  end

  def destroy
    @presenca = @aula.presencas.find(params[:id])

    if @presenca.destroy
      redirect_to @aula,
        notice: "Presença removida.",
        status: :see_other
    else
      redirect_to @aula,
        alert: "Erro ao remover presença.",
        status: :unprocessable_entity
    end
  end

  # GET /presenca/:code/checkin
  def checkin
    aula = Aula.find_by!(code: params[:code])
    aluno = Aluno.find(2) # depois vem do login

    presenca = Presenca.find_or_initialize_by(
      aluno: aluno,
      aula: aula
    )

    if aula.data != Date.today
      render plain: "Check-in fora da data da aula", status: :unprocessable_entity
      return
    end

    if presenca.presente?
      render plain: "Presença já registrada"
    else
      presenca.presente = true
      presenca.save!
      render plain: "Check-in confirmado em #{aula.horario.turma.nome} para #{aula.data}"
    end
  end

  private

  def set_aula
    @aula = Aula.find(params[:aula_id])
  end
end
