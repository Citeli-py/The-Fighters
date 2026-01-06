class TurmaAlunosController < ApplicationController
  before_action :set_turma, only: %i[ new create ]

  def new
    @turma_aluno = TurmaAluno.new
    @alunos_disponiveis = Aluno.where.not(
      id: @turma.alunos.select(:id)
    )
  end

  def create
    @turma_aluno = @turma.turma_alunos.new(turma_aluno_params)

    if @turma_aluno.save
      redirect_to @turma, notice: "Aluno adicionado à turma."
    else
      @alunos_disponiveis = Aluno.where.not(
        id: @turma.alunos.select(:id)
      )
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    turma_aluno = TurmaAluno.find_by!(
      turma_id: params[:turma_id],
      aluno_id: params[:id]
    )

    turma_aluno.destroy

    redirect_to turma_path(params[:turma_id]), notice: "Aluno removido da turma."
  end


  private

  def set_turma
    @turma = Turma.find(params[:turma_id])
  end

  def turma_aluno_params
    params.require(:turma_aluno).permit(:aluno_id)
  end
end
