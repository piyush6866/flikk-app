class Brand::SubmissionsController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_brand!
  before_action :set_submission, only: [:show, :approve_creator, :reject_creator, :approve_content, :request_revision]

  def index
    @tab = params[:tab] || 'applications'
    
    case @tab
    when 'applications'
      @submissions = brand_submissions.pending_approval.includes(:user, :campaign).recent
    when 'in_progress'
      @submissions = brand_submissions.where(status: [:approved_to_upload, :uploaded, :revision_requested]).includes(:user, :campaign).recent
    when 'completed'
      @submissions = brand_submissions.completed.includes(:user, :campaign).recent
    else
      @submissions = brand_submissions.includes(:user, :campaign).recent
    end

    @applications_count = brand_submissions.pending_approval.count
    @in_progress_count = brand_submissions.where(status: [:approved_to_upload, :uploaded, :revision_requested]).count
    @completed_count = brand_submissions.completed.count
  end

  def show
    # Show submission details with video preview
  end

  # Approve creator to start uploading
  def approve_creator
    @submission.approve_creator!
    redirect_to brand_submissions_path(tab: 'applications'), notice: "#{@submission.user.name} has been approved to upload content!"
  end

  # Reject creator application
  def reject_creator
    creator_name = @submission.user.name
    @submission.reject_creator!
    redirect_to brand_submissions_path(tab: 'applications'), notice: "Application from #{creator_name} has been declined."
  end

  # Approve the submitted content
  def approve_content
    # Check for sufficient funds first
    unless @submission.brand_has_sufficient_funds?
      redirect_to brand_submission_path(@submission), alert: "Insufficient wallet balance. Please add funds to approve this content. Required: #{@submission.formatted_brand_cost}"
      return
    end

    begin
      @submission.approve_content!
      redirect_to brand_submissions_path(tab: 'in_progress'), notice: "Content approved! #{@submission.user.name} has been paid #{@submission.formatted_creator_net}."
    rescue => e
      redirect_to brand_submission_path(@submission), alert: "Failed to approve content: #{e.message}"
    end
  end

  # Request revision with feedback
  def request_revision
    feedback = params[:feedback]
    if feedback.present?
      @submission.request_revision!(feedback)
      redirect_to brand_submissions_path(tab: 'in_progress'), notice: "Revision requested. #{@submission.user.name} has been notified."
    else
      redirect_to brand_submission_path(@submission), alert: "Please provide feedback for the revision request."
    end
  end

  private

  def brand_submissions
    Submission.joins(:campaign).where(campaigns: { user_id: current_user.id })
  end

  def set_submission
    @submission = brand_submissions.find(params[:id])
  end

  def ensure_brand!
    unless current_user.brand?
      redirect_to root_path, alert: "Access denied. This area is for brands only."
    end
  end
end

