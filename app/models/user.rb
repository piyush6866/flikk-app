class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # ActiveStorage for profile photo and intro video
  has_one_attached :profile_photo
  has_one_attached :intro_video

  # Associations
  has_many :campaigns, dependent: :destroy
  has_many :submissions, dependent: :destroy
  has_many :applied_campaigns, through: :submissions, source: :campaign
  has_many :wallet_transactions, dependent: :destroy

  # Creator status enum
  enum creator_status: {
    pending_approval: 0,
    approved: 1,
    rejected: 2
  }, _prefix: :creator

  # Callbacks
  before_create :auto_approve_creator

  # Validations
  validates :role, presence: true, inclusion: { in: %w[brand creator] }
  validates :brand_name, presence: true, if: :brand?
  validates :name, presence: true, if: :creator?
  validates :phone_number, presence: true, if: :creator?

  # Scopes for creators
  scope :creators, -> { where(role: 'creator') }
  scope :approved_creators, -> { creators.where(creator_status: :approved) }
  scope :pending_creators, -> { creators.where(creator_status: :pending_approval) }
  scope :top_rated, -> { approved_creators.order(rating: :desc) }
  scope :new_creators, -> { approved_creators.order(created_at: :desc) }

  # Role methods
  def brand?
    role == "brand"
  end

  def creator?
    role == "creator"
  end

  # Display name helper
  def display_name
    brand? ? brand_name : name
  end

  # Creator helper methods
  def can_accept_jobs?
    creator? && creator_approved?
  end

  def niches_array
    niches.to_s.split(',').map(&:strip)
  end

  def niches_array=(arr)
    self.niches = arr.join(', ')
  end

  def formatted_price
    "₹#{price_per_video.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse}"
  end

  def approval_rate
    return 0 if submissions.count.zero?
    (submissions.completed.count.to_f / submissions.count * 100).round
  end

  def initials
    display_name.to_s.split.map(&:first).join.upcase[0..1]
  end

  # Wallet methods
  def formatted_wallet_balance
    balance = wallet_balance || 0
    "₹#{balance.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse}"
  end

  def add_to_wallet(amount, description: 'Wallet top-up')
    return false if amount <= 0

    transaction do
      increment!(:wallet_balance, amount)
      wallet_transactions.create!(
        amount: amount,
        transaction_type: :credit,
        description: description
      )
    end
    true
  rescue => e
    Rails.logger.error "Failed to add wallet funds: #{e.message}"
    false
  end

  def deduct_from_wallet(amount, submission: nil, description: 'Payment')
    return false if amount <= 0
    return false if (wallet_balance || 0) < amount

    transaction do
      decrement!(:wallet_balance, amount)
      wallet_transactions.create!(
        amount: amount,
        transaction_type: :debit,
        description: description,
        related_submission: submission
      )
    end
    true
  rescue => e
    Rails.logger.error "Failed to deduct wallet funds: #{e.message}"
    false
  end

  def credit_payout(amount, submission:, description: 'Creator payout')
    return false if amount <= 0

    transaction do
      increment!(:wallet_balance, amount)
      wallet_transactions.create!(
        amount: amount,
        transaction_type: :payout,
        description: description,
        related_submission: submission
      )
    end
    true
  rescue => e
    Rails.logger.error "Failed to credit payout: #{e.message}"
    false
  end

  private

  def auto_approve_creator
    # Auto-approve creators on signup for MVP
    # Can add manual approval workflow later
    self.creator_status = :approved if creator?
  end
end
