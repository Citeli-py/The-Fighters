class PerfilController < ApplicationController
  def edit
  end

  def update
    if current_user.update_with_password(perfil_params)
      bypass_sign_in(current_user)
      redirect_to perfil_path, notice: "Senha alterada com sucesso."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def perfil_params
    params.require(:user).permit(:current_password, :password, :password_confirmation)
  end
end
