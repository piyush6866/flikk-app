class Brand::CreatorsController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_brand!
  before_action :set_creator, only: [:show]

  def index
    @filter = params[:filter] || 'discover'
    
    @creators = case @filter
    when 'discover'
      User.approved_creators.order(rating: :desc, videos_completed: :desc)
    when 'new'
      User.approved_creators.where('created_at > ?', 30.days.ago).order(created_at: :desc)
    when 'previous_hires'
      previous_hire_ids = Submission.joins(:campaign)
        .where(campaigns: { user_id: current_user.id })
        .where(status: [:content_approved, :paid])
        .pluck(:user_id).uniq
      User.where(id: previous_hire_ids)
    when 'favorites'
      # TODO: Implement favorites functionality
      User.none
    when 'ad_performers'
      User.approved_creators.where('rating >= ?', 4.5).order(rating: :desc)
    else
      User.approved_creators
    end

    # Apply additional filters
    if params[:niche].present?
      @creators = @creators.where('niches ILIKE ?', "%#{params[:niche]}%")
    end

    if params[:location].present?
      @creators = @creators.where('location ILIKE ?', "%#{params[:location]}%")
    end

    if params[:min_price].present? && params[:max_price].present?
      @creators = @creators.where(price_per_video: params[:min_price].to_i..params[:max_price].to_i)
    end

    @creators = @creators.page(params[:page]).per(12) if @creators.respond_to?(:page)
  end

  def show
    # Show creator profile in modal or dedicated page
  end

  private

  def set_creator
    @creator = User.approved_creators.find(params[:id])
  end

  def ensure_brand!
    unless current_user.brand?
      redirect_to root_path, alert: "Access denied. This area is for brands only."
    end
  end
end

