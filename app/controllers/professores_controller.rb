class ProfessoresController < ApplicationController
  before_action :require_admin_or_professor!
  before_action :require_admin!, only: %i[new create edit update destroy reset_password]
  before_action :set_professor, only: %i[ show edit update destroy reset_password ]

  def index
    @professores = Professor.includes(:user).order(:nome)
  end

  def show
  end

  def new
    @professor = Professor.new
  end

  def create
    result = ProfessoresService.create(
      nome:            professor_params[:nome],
      cpf:             professor_params[:cpf],
      email:           professor_params[:user_email],
      data_nascimento: professor_params[:data_nascimento]
    )

    @professor = result[:professor]
    flash[:temp_password] = result[:password]
    redirect_to @professor, notice: "Professor criado."
  rescue ActiveRecord::RecordInvalid => e
    @professor = Professor.new(professor_params)
    @professor.errors.add(:base, e.message)
    render :new, status: :unprocessable_entity
  end

  def edit
  end

  def update
    ActiveRecord::Base.transaction do
      @professor.update!(professor_params.except(:cpf, :user_email))
      @professor.user.update!(email: professor_params[:user_email]) if professor_params[:user_email].present?
    end
    redirect_to @professor, notice: "Professor atualizado.", status: :see_other
  rescue ActiveRecord::RecordInvalid => e
    @professor.errors.add(:base, e.message)
    render :edit, status: :unprocessable_entity
  end

  def destroy
    user = @professor.user
    @professor.destroy!
    user.destroy!
    redirect_to professores_path, notice: "Professor removido.", status: :see_other
  end

  # PATCH /professores/:id/reset_password
  def reset_password
    new_password = ProfessoresService.reset_password(@professor)
    flash[:temp_password] = new_password
    redirect_to @professor, notice: "Senha resetada."
  end

  private

  def set_professor
    @professor = Professor.find(params[:id])
  end

  def professor_params
    params.expect(professor: [ :nome, :cpf, :data_nascimento, :user_email ])
  end
end
