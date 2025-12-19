class Creator::DashboardController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_creator!

  def show
  end

  private

  def ensure_creator!
    unless current_user.creator?
      redirect_to root_path, alert: "Access denied. This area is for creators only."
    end
  end
end

