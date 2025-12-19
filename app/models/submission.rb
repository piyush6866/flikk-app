class Submission < ApplicationRecord
  belongs_to :campaign
  belongs_to :user

  # ActiveStorage attachment for video
  has_one_attached :video

  # Status enum for workflow
  enum status: {
    started: 0,
    submitted: 1,
    approved: 2,
    rejected: 3,
    paid: 4
  }

  # Validations
  validates :campaign_id, uniqueness: { scope: :user_id, message: "You've already applied to this campaign" }
  validates :payout_amount, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

  # Scopes
  scope :active, -> { where(status: [:started, :rejected]) }
  scope :under_review, -> { where(status: :submitted) }
  scope :completed, -> { where(status: [:approved, :paid]) }
  scope :recent, -> { order(created_at: :desc) }

  # Callbacks
  before_create :set_payout_amount

  # Helper methods
  def formatted_payout
    "₹#{payout_amount.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse}"
  end

  def status_label
    case status
    when 'started' then 'To Do'
    when 'submitted' then 'Under Review'
    when 'approved' then 'Approved'
    when 'rejected' then 'Revision Needed'
    when 'paid' then 'Paid'
    else status.humanize
    end
  end

  def status_color
    case status
    when 'started' then 'amber'
    when 'submitted' then 'blue'
    when 'approved' then 'emerald'
    when 'rejected' then 'rose'
    when 'paid' then 'green'
    else 'slate'
    end
  end

  def progress_step
    case status
    when 'started' then 1
    when 'submitted' then 2
    when 'approved', 'rejected' then 3
    when 'paid' then 4
    else 0
    end
  end

  def can_upload?
    started? || rejected?
  end

  def has_content?
    video.attached? || external_link.present?
  end

  private

  def set_payout_amount
    self.payout_amount ||= campaign&.price || 0
  end
end
