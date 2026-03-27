class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  before_action :authenticate_user!

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  layout :layout_by_resource

  def require_admin!
    redirect_to root_path, alert: "Acesso negado" unless current_user.admin?
  end

  private

  def layout_by_resource
    devise_controller? ? "auth" : "application"
  end
end
