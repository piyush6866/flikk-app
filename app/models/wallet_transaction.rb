class WalletTransaction < ApplicationRecord
  belongs_to :user
  belongs_to :related_submission, class_name: 'Submission', optional: true

  enum transaction_type: {
    credit: 0,    # Money added to wallet
    debit: 1,     # Money deducted (payment to creator)
    refund: 2,    # Refund
    payout: 3     # Creator payout
  }

  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :transaction_type, presence: true

  scope :recent, -> { order(created_at: :desc) }
  scope :credits, -> { where(transaction_type: :credit) }
  scope :debits, -> { where(transaction_type: :debit) }

  def formatted_amount
    prefix = credit? || refund? || payout? ? '+' : '-'
    "#{prefix}₹#{amount.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse}"
  end

  def amount_color
    credit? || refund? || payout? ? 'text-emerald-600' : 'text-rose-600'
  end

  def icon_bg
    if payout?
      'bg-emerald-100'
    elsif credit? || refund?
      'bg-emerald-100'
    else
      'bg-rose-100'
    end
  end

  def icon_color
    if payout?
      'text-emerald-600'
    elsif credit? || refund?
      'text-emerald-600'
    else
      'text-rose-600'
    end
  end
end
