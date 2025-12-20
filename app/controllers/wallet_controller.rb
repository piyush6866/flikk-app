class WalletController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_brand!, only: [:add_funds]

  def show
    @transactions = current_user.wallet_transactions.recent.includes(:related_submission).limit(50)
    
    if current_user.brand?
      @total_credited = current_user.wallet_transactions.credits.sum(:amount)
      @total_debited = current_user.wallet_transactions.debits.sum(:amount)
      @pending_payments = pending_brand_payments
    else
      # Creator stats
      @total_earned = current_user.wallet_transactions.where(transaction_type: :payout).sum(:amount)
      @pending_payout = pending_creator_earnings
      @total_withdrawn = current_user.wallet_transactions.debits.sum(:amount)
    end
  end

  def add_funds
    amount = params[:amount].to_i

    if amount < 100
      render json: { success: false, message: 'Minimum amount is ₹100' }, status: :unprocessable_entity
      return
    end

    if amount > 1_000_000
      render json: { success: false, message: 'Maximum amount is ₹10,00,000' }, status: :unprocessable_entity
      return
    end

    if current_user.add_to_wallet(amount)
      render json: { 
        success: true, 
        message: 'Funds added successfully!',
        new_balance: current_user.wallet_balance,
        formatted_balance: current_user.formatted_wallet_balance
      }
    else
      render json: { success: false, message: 'Failed to add funds. Please try again.' }, status: :unprocessable_entity
    end
  end

  def transaction_details
    @transaction = current_user.wallet_transactions.find(params[:id])
    
    respond_to do |format|
      format.json do
        submission_data = nil
        if @transaction.related_submission
          sub = @transaction.related_submission
          if current_user.brand?
            submission_data = {
              campaign_title: sub.campaign.title,
              creator_name: sub.user.name,
              creator_payout: sub.formatted_payout,
              platform_fee: "₹#{(sub.payout_amount * 0.10).round}",
              brand_total: sub.formatted_brand_cost
            }
          else
            submission_data = {
              campaign_title: sub.campaign.title,
              brand_name: sub.campaign.user.brand_name,
              gross_amount: sub.formatted_payout,
              platform_fee: "₹#{(sub.payout_amount * 0.15).round}",
              net_payout: sub.formatted_creator_net
            }
          end
        end
        
        render json: {
          id: @transaction.id,
          amount: @transaction.amount,
          formatted_amount: @transaction.formatted_amount,
          transaction_type: @transaction.transaction_type,
          description: @transaction.description,
          created_at: @transaction.created_at.strftime('%B %d, %Y at %I:%M %p'),
          submission: submission_data
        }
      end
    end
  end

  private

  def ensure_brand!
    unless current_user.brand?
      render json: { success: false, message: 'Only brands can add funds' }, status: :forbidden
    end
  end

  # Calculate pending payments for brand (approved but not yet processed submissions)
  def pending_brand_payments
    Submission.joins(:campaign)
      .where(campaigns: { user_id: current_user.id })
      .where(status: [:approved_to_upload, :uploaded])
      .sum(:brand_total_cost)
  end

  # Calculate pending earnings for creator (content approved but not yet withdrawn)
  def pending_creator_earnings
    current_user.submissions
      .where(status: :content_approved)
      .sum(:creator_net_payout)
  end
end
