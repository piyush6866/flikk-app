class CreateCampaigns < ActiveRecord::Migration[7.1]
  def change
    create_table :campaigns do |t|
      t.string :title, null: false
      t.string :product_name, null: false
      t.string :product_url
      t.string :scenario, null: false
      t.string :aspect_ratio, null: false
      t.integer :duration, null: false, default: 30
      t.integer :price, null: false
      t.text :instructions
      t.integer :status, null: false, default: 1
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end

    add_index :campaigns, :status
    add_index :campaigns, :scenario
  end
end
