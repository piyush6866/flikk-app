class Submission < ApplicationRecord
  belongs_to :campaign
  belongs_to :user

  # ActiveStorage attachment for video
  has_one_attached :video

  # Platform fee constants
  BRAND_FEE_PERCENT = 10  # 10% from brand
  CREATOR_FEE_PERCENT = 15  # 15% from creator

  # Status enum for workflow:
  # applied -> approved_to_upload -> uploaded -> content_approved/revision_requested -> paid
  enum status: {
    applied: 0,              # Creator applied, waiting for brand to approve
    approved_to_upload: 1,   # Brand approved, creator can now upload
    uploaded: 2,             # Creator uploaded content, waiting for brand review
    content_approved: 3,     # Brand approved the content
    revision_requested: 4,   # Brand requested changes
    paid: 5                  # Creator has been paid
  }

  # Validations
  validates :campaign_id, uniqueness: { scope: :user_id, message: "You've already applied to this campaign" }
  validates :payout_amount, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

  # Scopes
  scope :pending_approval, -> { where(status: :applied) }
  scope :ready_to_upload, -> { where(status: [:approved_to_upload, :revision_requested]) }
  scope :under_review, -> { where(status: :uploaded) }
  scope :completed, -> { where(status: [:content_approved, :paid]) }
  scope :recent, -> { order(created_at: :desc) }

  # Callbacks
  before_create :set_payout_amount
  before_create :calculate_fees

  # Helper methods
  def formatted_payout
    amount = payout_amount || 0
    "₹#{amount.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse}"
  end

  def formatted_creator_net
    # Calculate on the fly - handles missing column gracefully
    amount = begin
      self[:creator_net_payout] || calculate_creator_net
    rescue
      calculate_creator_net
    end
    "₹#{amount.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse}"
  end

  def formatted_brand_cost
    # Calculate on the fly - handles missing column gracefully
    amount = begin
      self[:brand_total_cost] || calculate_brand_cost
    rescue
      calculate_brand_cost
    end
    "₹#{amount.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse}"
  end

  def calculate_creator_net
    base = payout_amount || 0
    base - (base * CREATOR_FEE_PERCENT / 100.0).round
  end

  def calculate_brand_cost
    base = payout_amount || 0
    base + (base * BRAND_FEE_PERCENT / 100.0).round
  end

  def status_label
    case status
    when 'applied' then 'Applied'
    when 'approved_to_upload' then 'Ready to Upload'
    when 'uploaded' then 'Under Review'
    when 'content_approved' then 'Approved'
    when 'revision_requested' then 'Revision Needed'
    when 'paid' then 'Paid'
    else status.humanize
    end
  end

  def status_color
    case status
    when 'applied' then 'amber'
    when 'approved_to_upload' then 'indigo'
    when 'uploaded' then 'blue'
    when 'content_approved' then 'emerald'
    when 'revision_requested' then 'rose'
    when 'paid' then 'green'
    else 'slate'
    end
  end

  def progress_step
    case status
    when 'applied' then 1
    when 'approved_to_upload' then 2
    when 'uploaded' then 3
    when 'content_approved', 'revision_requested' then 4
    when 'paid' then 5
    else 0
    end
  end

  def total_steps
    5
  end

  def can_upload?
    approved_to_upload? || revision_requested?
  end

  def has_content?
    video.attached? || external_link.present?
  end

  # Workflow actions
  def approve_creator!
    update!(status: :approved_to_upload)
  end

  def reject_creator!
    destroy  # Remove the application
  end

  def submit_content!
    update!(status: :uploaded)
  end

  def approve_content!
    brand = campaign.user
    creator = user
    
    # Deduct from brand's wallet - use calculated values to handle missing columns
    brand_cost = calculate_brand_cost
    unless brand.deduct_from_wallet(brand_cost, submission: self, description: "Payment for #{campaign.title.truncate(30)}")
      raise "Insufficient wallet balance"
    end
    
    # Credit to creator's wallet
    creator_payout = calculate_creator_net
    creator.credit_payout(creator_payout, submission: self, description: "Payout for #{campaign.title.truncate(30)}")
    
    update!(status: :content_approved, approved_at: Time.current)
  end

  def request_revision!(feedback)
    update!(status: :revision_requested, brand_feedback: feedback, revision_count: (revision_count || 0) + 1)
  end

  def mark_paid!
    update!(status: :paid, paid_at: Time.current)
  end

  def brand_has_sufficient_funds?
    brand = campaign.user
    brand_cost = calculate_brand_cost
    (brand.wallet_balance || 0) >= brand_cost
  end

  private

  def set_payout_amount
    self.payout_amount ||= campaign&.price || 0
  end

  def calculate_fees
    base_price = payout_amount || 0
    # Brand pays base + 10% platform fee
    self.platform_fee_brand = (base_price * BRAND_FEE_PERCENT / 100.0).round
    self.brand_total_cost = base_price + platform_fee_brand
    # Creator gets base - 15% platform fee  
    self.platform_fee_creator = (base_price * CREATOR_FEE_PERCENT / 100.0).round
    self.creator_net_payout = base_price - platform_fee_creator
  end
end
