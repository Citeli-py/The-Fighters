class AulasController < ApplicationController
  before_action :set_aula, only: %i[ show cancel_aula confirm_aula ]
  before_action :require_admin_or_professor!, only: %i[cancel_aula confirm_aula]


  # GET /aulas/1 or /aulas/1.json
  def show
    @presencas = @aula.presencas.includes(:aluno)

    turma = @aula.horario.turma

    # alunos da turma que ainda NÃO marcaram presença
    @alunos_disponiveis = turma.alunos.where.not(id: @presencas.select(:aluno_id))

    if current_user.admin?
      qr_url = presenca_checkin_url(code: @aula.code)
      @qr = RQRCode::QRCode.new(qr_url)
    end
  end


  def index
    today = Date.current

    @turmas      = Turma.order(:nome)
    @modalidades = Modalidade.order(:nome)

    scope = Aula.includes(horario: { turma: :modalidade })
                .joins(horario: { turma: :modalidade })

    scope = scope.where(horarios: { turma_id: params[:turma_id] }) if params[:turma_id].present?
    scope = scope.where(turmas: { modalidade_id: params[:modalidade_id] }) if params[:modalidade_id].present?

    @aulas_semana   = scope.where(data: today.beginning_of_week..today.end_of_week).order(:data)
    @aulas_proximas = scope.where("aulas.data > ?", today.end_of_week).order(:data)
    @aulas_passadas = scope.where("aulas.data < ?", today.beginning_of_week).order(data: :desc)
  end

  # PATCH /aulas/:id/cancel
  def cancel_aula
    respond_to do |format|
      if @aula.cancel!
        format.html do
          redirect_to aulas_path,
            notice: "Aula #{@aula.code} cancelada com sucesso.",
            status: :see_other
        end

        format.json do
          render json: {
            data: @aula,
            notice: "Aula #{@aula.code} cancelada com sucesso."
          }, status: :ok
        end
      else
        format.html do
          redirect_to aulas_path,
            alert: "Erro ao cancelar aula.",
            status: :unprocessable_entity
        end

        format.json do
          render json: {
            alert: "Erro ao cancelar aula",
            errors: @aula.errors.full_messages
          }, status: :unprocessable_entity
        end
      end
    end
  end

  # PATCH /aulas/:id/confirm
  def confirm_aula
    respond_to do |format|
      if @aula.confirm!
        format.html do
          redirect_to aulas_path,
            notice: "Aula #{@aula.code} confirmada com sucesso.",
            status: :see_other
        end

        format.json do
          render json: {
            data: @aula,
            notice: "Aula #{@aula.code} confirmada com sucesso."
          }, status: :ok
        end
      else
        format.html do
          redirect_to aulas_path,
            alert: "Erro ao confirmar aula.",
            status: :unprocessable_entity
        end

        format.json do
          render json: {
            alert: "Erro ao confirmar aula",
            errors: @aula.errors.full_messages
          }, status: :unprocessable_entity
        end
      end
    end
  end


  private

  def set_aula
    @aula = Aula.find(params.expect(:id))
  end

  def set_aula_by_code
    @aula = Aula.find_by(code: params.expect(:code))
  end

  # Only allow a list of trusted parameters through.
  def aula_params
    params.expect(aula: [ :horario_id, :status, :data ])
  end
end
