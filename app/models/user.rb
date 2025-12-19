class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

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
end
