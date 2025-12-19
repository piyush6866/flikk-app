class Campaign < ApplicationRecord
  belongs_to :user

  # Status enum
  enum status: {
    draft: 0,
    live: 1,
    completed: 2,
    archived: 3
  }

  # Scenario options
  SCENARIOS = [
    'Unboxing',
    'Testimonial',
    'How-to',
    'Lifestyle'
  ].freeze

  # Aspect ratio options
  ASPECT_RATIOS = [
    ['9:16 (Reels/TikTok)', '9:16'],
    ['16:9 (YouTube)', '16:9'],
    ['1:1 (Feed)', '1:1']
  ].freeze

  # Duration options (in seconds)
  DURATIONS = [15, 30, 45, 60, 90, 120].freeze

  # Validations
  validates :title, presence: true, length: { minimum: 5, maximum: 100 }
  validates :product_name, presence: true
  validates :scenario, presence: true, inclusion: { in: SCENARIOS }
  validates :aspect_ratio, presence: true, inclusion: { in: ASPECT_RATIOS.map(&:last) }
  validates :duration, presence: true, inclusion: { in: DURATIONS }
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 500, less_than_or_equal_to: 100000 }
  validates :product_url, format: { with: URI::DEFAULT_PARSER.make_regexp(%w[http https]), message: 'must be a valid URL' }, allow_blank: true

  # Scopes
  scope :active, -> { where(status: :live) }
  scope :by_scenario, ->(scenario) { where(scenario: scenario) if scenario.present? }
  scope :recent, -> { order(created_at: :desc) }

  # Helper methods
  def formatted_price
    "₹#{price.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse}"
  end

  def duration_label
    if duration >= 60
      "#{duration / 60}m #{duration % 60 > 0 ? "#{duration % 60}s" : ''}"
    else
      "#{duration}s"
    end
  end

  def aspect_ratio_label
    ASPECT_RATIOS.find { |label, value| value == aspect_ratio }&.first || aspect_ratio
  end
end
