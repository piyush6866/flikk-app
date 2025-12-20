class AddCreatorProfileFields < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :bio, :text
    add_column :users, :location, :string
    add_column :users, :intro_video_url, :string
    add_column :users, :instagram_handle, :string
    add_column :users, :youtube_handle, :string
    add_column :users, :creator_status, :integer, default: 0  # 0: pending, 1: approved, 2: rejected
    add_column :users, :niches, :string  # comma-separated
    add_column :users, :rating, :decimal, precision: 3, scale: 2, default: 0.0
    add_column :users, :videos_completed, :integer, default: 0
    add_column :users, :price_per_video, :integer, default: 2500  # in INR
    
    add_index :users, :creator_status
  end
end
