class Users::RegistrationsController < Devise::RegistrationsController
  before_action :configure_sign_up_params, only: [:create]

  # GET /users/sign_up
  def new
    # Redirect to home if no role specified
    redirect_to root_path unless params[:role].present?
    @role = params[:role]
    super
  end

  # POST /users
  def create
    super
  end

  protected

  def configure_sign_up_params
    devise_parameter_sanitizer.permit(:sign_up, keys: [:role, :brand_name, :name, :phone_number])
  end

  def after_sign_up_path_for(resource)
    if resource.brand?
      brand_dashboard_path
    elsif resource.creator?
      creator_dashboard_path
    else
      root_path
    end
  end

  def build_resource(hash = {})
    super
    resource.role = params[:user][:role] if params[:user].present?
  end
end

