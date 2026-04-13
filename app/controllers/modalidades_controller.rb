class ModalidadesController < ApplicationController
  before_action :require_admin_or_professor!
  before_action :require_admin!, only: %i[ edit update destroy ]
  before_action :set_modalidade, only: %i[ show edit update destroy ]

  def index
    @modalidades = Modalidade.order(:nome)
  end

  def show
  end

  def new
    @modalidade = Modalidade.new
  end

  def edit
  end

  def create
    @modalidade = Modalidade.new(modalidade_params)

    if @modalidade.save
      redirect_to modalidades_path, notice: "Modalidade criada com sucesso."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @modalidade.update(modalidade_params)
      redirect_to modalidades_path, notice: "Modalidade atualizada com sucesso.", status: :see_other
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @modalidade.destroy!
    redirect_to modalidades_path, notice: "Modalidade excluída com sucesso.", status: :see_other
  end

  private

  def set_modalidade
    @modalidade = Modalidade.find(params.expect(:id))
  end

  def modalidade_params
    params.expect(modalidade: [ :nome ])
  end
end
