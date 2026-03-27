class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  before_action :authenticate_user!
  before_action :configure_permitted_parameters, if: :devise_controller?

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  layout :layout_by_resource

  def require_admin!
    redirect_to root_path, alert: "Acesso negado" unless current_user.admin?
  end

  def require_admin_or_professor!
    redirect_to root_path, alert: "Acesso negado" unless current_user.admin_or_professor?
  end

  private

  def layout_by_resource
    devise_controller? ? "auth" : "application"
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_in, keys: [:username])
  end
end
