class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # Associations
  has_many :campaigns, dependent: :destroy
  has_many :submissions, dependent: :destroy
  has_many :applied_campaigns, through: :submissions, source: :campaign

  # Validations
  validates :role, presence: true, inclusion: { in: %w[brand creator] }
  validates :brand_name, presence: true, if: :brand?
  validates :name, presence: true, if: :creator?
  validates :phone_number, presence: true, if: :creator?

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
end
