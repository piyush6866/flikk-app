class Brand::DashboardController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_brand!

  def show
    @campaigns = current_user.campaigns.recent
    @active_campaigns = @campaigns.active.count
    @total_spent = @campaigns.sum(:price)
  end

  private

  def ensure_brand!
    unless current_user.brand?
      redirect_to root_path, alert: "Access denied. This area is for brands only."
    end
  end
end

