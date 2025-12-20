class Brand::DashboardController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_brand!

  def show
    @campaigns = current_user.campaigns.includes(:submissions).recent
    @active_campaigns_count = @campaigns.active.count
    @total_campaigns = @campaigns.count
    @total_spent = @campaigns.sum(:price)
    
    # All submissions for this brand's campaigns
    @all_submissions = Submission.joins(:campaign)
      .where(campaigns: { user_id: current_user.id })
      .includes(:user, :campaign)
      .order(created_at: :desc)
    
    # Categorized submissions
    @applications = @all_submissions.where(status: :applied)
    @in_progress_submissions = @all_submissions.where(status: [:approved_to_upload, :uploaded, :revision_requested])
    @completed_submissions = @all_submissions.where(status: [:content_approved, :paid])
    
    # Stats
    @applications_count = @applications.count
    @in_progress_count = @in_progress_submissions.count
    @completed_count = @completed_submissions.count
    @creators_hired = @completed_submissions.select(:user_id).distinct.count
    
    # Active tab
    @tab = params[:tab] || 'campaigns'
    
    # Current tab content
    @current_submissions = case @tab
    when 'applications'
      @applications
    when 'in_progress'
      @in_progress_submissions
    when 'completed'
      @completed_submissions
    else
      nil
    end
  end

  private

  def ensure_brand!
    unless current_user.brand?
      redirect_to root_path, alert: "Access denied. This area is for brands only."
    end
  end
end
