class PresencasController < ApplicationController
  before_action :require_admin!, only: %i[ create destroy ]
  before_action :set_aula, only: %i[ create destroy ]

  def create
    @presenca = @aula.presencas.build(aluno_id: params[:aluno_id])

    if @presenca.save
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to @aula, notice: "Presença registrada.", status: :see_other }
      end
    else
      respond_to do |format|
        format.html { redirect_to @aula, alert: @presenca.errors.full_messages.to_sentence, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @presenca = @aula.presencas.find(params[:id])

    if @presenca.destroy
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to @aula, notice: "Presença removida.", status: :see_other }
      end
    else
      respond_to do |format|
        format.html { redirect_to @aula, alert: "Erro ao remover presença.", status: :unprocessable_entity }
      end
    end
  end

  # GET /presenca/:code/checkin
  def checkin
    aula = Aula.find_by(code: params[:code])
    return redirect_to root_path, alert: "QR Code inválido." if aula.nil?

    aluno = Aluno.find_by(user: current_user)
    return redirect_to root_path, alert: "Seu usuário não está vinculado a nenhum aluno. Fale com o professor." if aluno.nil?

    if aula.data != Date.today
      return redirect_to root_path, alert: "Este QR Code é de uma aula de outro dia."
    end

    presenca = Presenca.find_or_initialize_by(aluno: aluno, aula: aula)

    if presenca.persisted?
      redirect_to root_path, notice: "Presença já registrada em #{aula.horario.turma.nome}."
    else
      presenca.save!
      redirect_to root_path, notice: "Check-in confirmado em #{aula.horario.turma.nome}!"
    end
  end

  private

  def set_aula
    @aula = Aula.find(params[:aula_id])
  end
end
