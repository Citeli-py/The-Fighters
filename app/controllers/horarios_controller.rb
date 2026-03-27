class HorariosController < ApplicationController
  before_action :require_admin!
  before_action :set_horario, only: %i[ show edit update destroy ]

  # GET /horarios or /horarios.json
  def index
    @horarios = Horario.all
  end

  # GET /horarios/1 or /horarios/1.json
  def show
  end

  # GET /horarios/new
  def new
    @horario = Horario.new(turma_id: params[:turma_id])
  end


  # GET /horarios/1/edit
  def edit
  end

  # POST /horarios or /horarios.json
  def create
    @horario = Horario.new(horario_params)

    respond_to do |format|
      if @horario.save
        format.html { redirect_to @horario, notice: "Horario was successfully created." }
        format.json { render :show, status: :created, location: @horario }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @horario.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /horarios/1 or /horarios/1.json
  def update
    respond_to do |format|
      if @horario.update(horario_params)
        format.html { redirect_to @horario, notice: "Horario was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @horario }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @horario.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /horarios/1 or /horarios/1.json
  def destroy
    @horario.destroy!

    respond_to do |format|
      format.html { redirect_to horarios_path, notice: "Horario was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_horario
      @horario = Horario.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def horario_params
      params.expect(horario: [ :turma_id, :dia_semana, :hora_inicio, :hora_fim ])
    end
end
