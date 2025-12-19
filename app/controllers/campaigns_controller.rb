class CampaignsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_campaign, only: [:show, :edit, :update, :destroy]
  before_action :authorize_brand!, only: [:new, :create, :edit, :update, :destroy]
  before_action :authorize_creator!, only: [:index]
  before_action :authorize_owner!, only: [:edit, :update, :destroy]

  # GET /campaigns - Creator Marketplace (Job Board)
  def index
    @campaigns = Campaign.active.recent.includes(:user)
    
    # Filter by scenario if provided
    @campaigns = @campaigns.by_scenario(params[:scenario]) if params[:scenario].present?
  end

  # GET /campaigns/:id - Campaign Details
  def show
    # Both brands and creators can view campaign details
  end

  # GET /campaigns/new - Brand: Create New Campaign
  def new
    @campaign = current_user.campaigns.build
  end

  # POST /campaigns - Brand: Create Campaign
  def create
    @campaign = current_user.campaigns.build(campaign_params)
    
    if @campaign.save
      redirect_to brand_dashboard_path, notice: 'Campaign created successfully! It is now live for creators to see.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  # GET /campaigns/:id/edit - Brand: Edit Campaign
  def edit
  end

  # PATCH/PUT /campaigns/:id - Brand: Update Campaign
  def update
    if @campaign.update(campaign_params)
      redirect_to brand_dashboard_path, notice: 'Campaign updated successfully.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /campaigns/:id - Brand: Delete Campaign
  def destroy
    @campaign.destroy
    redirect_to brand_dashboard_path, notice: 'Campaign was deleted.'
  end

  private

  def set_campaign
    @campaign = Campaign.find(params[:id])
  end

  def campaign_params
    params.require(:campaign).permit(
      :title,
      :product_name,
      :product_url,
      :scenario,
      :aspect_ratio,
      :duration,
      :price,
      :instructions,
      :status
    )
  end

  def authorize_brand!
    unless current_user.brand?
      redirect_to root_path, alert: 'Only brands can create campaigns.'
    end
  end

  def authorize_creator!
    unless current_user.creator?
      redirect_to root_path, alert: 'Only creators can access the job board.'
    end
  end

  def authorize_owner!
    unless @campaign.user_id == current_user.id
      redirect_to root_path, alert: 'You are not authorized to modify this campaign.'
    end
  end
end

