class CreateSubmissions < ActiveRecord::Migration[7.1]
  def change
    create_table :submissions do |t|
      t.references :campaign, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.string :external_link
      t.integer :status, default: 0, null: false
      t.integer :payout_amount, default: 0

      t.timestamps
    end

    # Prevent duplicate submissions (one creator per campaign)
    add_index :submissions, [:campaign_id, :user_id], unique: true
  end
end
