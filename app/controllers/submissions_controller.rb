class SubmissionsController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_creator!
  before_action :set_submission, only: [:show, :edit, :update]
  before_action :authorize_submission!, only: [:show, :edit, :update]

  # POST /submissions - Apply to a campaign
  def create
    @campaign = Campaign.find(params[:campaign_id])
    
    # Check if already applied
    existing = current_user.submissions.find_by(campaign: @campaign)
    if existing
      redirect_to creator_dashboard_path, alert: "You've already applied to this campaign."
      return
    end

    @submission = current_user.submissions.build(
      campaign: @campaign,
      status: :applied,  # New workflow: starts as "applied", waiting for brand approval
      payout_amount: @campaign.price
    )

    if @submission.save
      redirect_to creator_dashboard_path, notice: "Successfully applied to '#{@campaign.product_name}'! The brand will review your application."
    else
      redirect_to campaigns_path, alert: "Unable to apply. Please try again."
    end
  end

  # GET /submissions/:id - View submission details
  def show
  end

  # GET /submissions/:id/edit - Upload content form
  def edit
    unless @submission.can_upload?
      redirect_to creator_dashboard_path, alert: "You cannot upload content at this stage."
    end
  end

  # PATCH /submissions/:id - Submit content
  def update
    unless @submission.can_upload?
      redirect_to creator_dashboard_path, alert: "You cannot modify this submission."
      return
    end

    # Handle video upload or external link
    if params[:submission][:video].present?
      @submission.video.attach(params[:submission][:video])
    end

    if params[:submission][:external_link].present?
      @submission.external_link = params[:submission][:external_link]
    end

    # Check if content was provided
    unless @submission.video.attached? || @submission.external_link.present?
      redirect_to edit_submission_path(@submission), alert: "Please upload a video or provide an external link."
      return
    end

    # Update status to uploaded (waiting for brand review)
    @submission.status = :uploaded

    if @submission.save
      redirect_to creator_dashboard_path, notice: "Content submitted successfully! The brand will review it shortly."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_submission
    @submission = Submission.find(params[:id])
  end

  def ensure_creator!
    unless current_user.creator?
      redirect_to root_path, alert: "Access denied. This area is for creators only."
    end
  end

  def authorize_submission!
    unless @submission.user_id == current_user.id
      redirect_to creator_dashboard_path, alert: "You are not authorized to access this submission."
    end
  end
end

