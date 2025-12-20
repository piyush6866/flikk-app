class AddSubmissionWorkflowFields < ActiveRecord::Migration[7.1]
  def change
    add_column :submissions, :brand_feedback, :text
    add_column :submissions, :creator_net_payout, :integer, default: 0
    add_column :submissions, :brand_total_cost, :integer, default: 0
    add_column :submissions, :platform_fee_creator, :integer, default: 0
    add_column :submissions, :platform_fee_brand, :integer, default: 0
    add_column :submissions, :approved_at, :datetime
    add_column :submissions, :paid_at, :datetime
    add_column :submissions, :revision_count, :integer, default: 0
  end
end
