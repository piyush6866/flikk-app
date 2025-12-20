class WalletController < ApplicationController
  before_action :authenticate_user!

  def show
    @transactions = current_user.wallet_transactions.recent.includes(:related_submission).limit(50)
    @total_credited = current_user.wallet_transactions.credits.sum(:amount)
    @total_debited = current_user.wallet_transactions.debits.sum(:amount)
    @total_payouts = current_user.wallet_transactions.where(transaction_type: :payout).sum(:amount)
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
        render json: {
          id: @transaction.id,
          amount: @transaction.amount,
          formatted_amount: @transaction.formatted_amount,
          transaction_type: @transaction.transaction_type,
          description: @transaction.description,
          created_at: @transaction.created_at.strftime('%B %d, %Y at %I:%M %p'),
          submission: @transaction.related_submission ? {
            campaign_title: @transaction.related_submission.campaign.title,
            creator_payout: @transaction.related_submission.formatted_payout,
            platform_fee: "₹#{(@transaction.related_submission.payout_amount * 0.10).round}",
            brand_total: @transaction.related_submission.formatted_brand_cost
          } : nil
        }
      end
    end
  end
end

