class CreateWalletTransactions < ActiveRecord::Migration[7.1]
  def change
    create_table :wallet_transactions do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :amount, null: false
      t.integer :transaction_type, null: false, default: 0
      t.string :description
      t.references :related_submission, foreign_key: { to_table: :submissions }

      t.timestamps
    end
    
    add_index :wallet_transactions, [:user_id, :created_at]
  end
end
