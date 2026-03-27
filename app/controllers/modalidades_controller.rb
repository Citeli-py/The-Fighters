class ModalidadesController < ApplicationController
  before_action :require_admin!
  before_action :set_modalidade, only: %i[ show edit update destroy ]

  # GET /modalidades or /modalidades.json
  def index
    @modalidades = Modalidade.all
  end

  # GET /modalidades/1 or /modalidades/1.json
  def show
  end

  # GET /modalidades/new
  def new
    @modalidade = Modalidade.new
  end

  # GET /modalidades/1/edit
  def edit
  end

  # POST /modalidades or /modalidades.json
  def create
    @modalidade = Modalidade.new(modalidade_params)

    respond_to do |format|
      if @modalidade.save
        format.html { redirect_to @modalidade, notice: "Modalidade was successfully created." }
        format.json { render :show, status: :created, location: @modalidade }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @modalidade.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /modalidades/1 or /modalidades/1.json
  def update
    respond_to do |format|
      if @modalidade.update(modalidade_params)
        format.html { redirect_to @modalidade, notice: "Modalidade was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @modalidade }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @modalidade.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /modalidades/1 or /modalidades/1.json
  def destroy
    @modalidade.destroy!

    respond_to do |format|
      format.html { redirect_to modalidades_path, notice: "Modalidade was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_modalidade
      @modalidade = Modalidade.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def modalidade_params
      params.expect(modalidade: [ :nome ])
    end
end
