class Brand::DashboardController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_brand!

  def show
    @campaigns = current_user.campaigns.recent
    @active_campaigns = @campaigns.active.count
    @total_campaigns = @campaigns.count
    @total_spent = @campaigns.sum(:price)
    
    # Submission stats
    @submissions = Submission.joins(:campaign).where(campaigns: { user_id: current_user.id })
    @pending_applications = @submissions.where(status: :applied).count
    @in_progress = @submissions.where(status: [:approved_to_upload, :uploaded, :revision_requested]).count
    @completed = @submissions.where(status: [:content_approved, :paid]).count
    @creators_hired = @submissions.where(status: [:content_approved, :paid]).select(:user_id).distinct.count
  end

  private

  def ensure_brand!
    unless current_user.brand?
      redirect_to root_path, alert: "Access denied. This area is for brands only."
    end
  end
end
