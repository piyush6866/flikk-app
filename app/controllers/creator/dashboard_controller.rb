class Creator::DashboardController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_creator!

  def show
    # All submissions for this creator
    @submissions = current_user.submissions.includes(:campaign).recent

    # Active tasks (To-Do: needs upload or revision)
    @active_tasks = @submissions.active

    # Under review (waiting for brand)
    @under_review = @submissions.under_review

    # Completed tasks (approved or paid)
    @completed_tasks = @submissions.completed

    # Earnings calculations
    @total_earned = @submissions.where(status: :paid).sum(:payout_amount)
    @pending_payout = @submissions.where(status: :approved).sum(:payout_amount)

    # Available campaigns (excluding already applied)
    applied_campaign_ids = @submissions.pluck(:campaign_id)
    @available_campaigns = Campaign.active.where.not(id: applied_campaign_ids).recent.limit(5)
    @total_available = Campaign.active.where.not(id: applied_campaign_ids).count
  end

  private

  def ensure_creator!
    unless current_user.creator?
      redirect_to root_path, alert: "Access denied. This area is for creators only."
    end
  end
end

