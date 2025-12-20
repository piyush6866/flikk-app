class Creator::DashboardController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_creator!

  def show
    # All submissions for this creator
    @submissions = current_user.submissions.includes(:campaign).recent

    # Pending approval (waiting for brand to approve application)
    @pending_approval = @submissions.pending_approval

    # Ready to upload (approved by brand, can now upload)
    @ready_to_upload = @submissions.ready_to_upload

    # Under review (content uploaded, waiting for brand review)
    @under_review = @submissions.under_review

    # Completed tasks (content approved or paid)
    @completed_tasks = @submissions.completed

    # Earnings calculations (use creator_net_payout which is after 15% fee)
    # Handle case where column may not exist yet (migration pending)
    begin
      @total_earned = @submissions.where(status: :paid).sum(:creator_net_payout)
      @pending_payout = @submissions.where(status: :content_approved).sum(:creator_net_payout)
    rescue ActiveRecord::StatementInvalid
      # Fallback if column doesn't exist yet
      @total_earned = 0
      @pending_payout = 0
    end

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

