# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

puts "🌱 Starting seed..."

# Clear existing data
puts "🧹 Cleaning up ALL existing data..."
WalletTransaction.destroy_all
Submission.destroy_all
Campaign.destroy_all
User.destroy_all

puts "✅ Database cleared!"

# ============================================
# CREATE TEST ACCOUNTS
# ============================================

puts ""
puts "👤 Creating test accounts..."

# Brand Account
brand = User.create!(
  email: "brand@flikk.com",
  password: "12345678",
  password_confirmation: "12345678",
  role: "brand",
  brand_name: "Test Brand",
  wallet_balance: 0
)

puts "  ✅ Brand account created"

# Creator Account
creator = User.create!(
  email: "creator@flikk.com",
  password: "12345678",
  password_confirmation: "12345678",
  role: "creator",
  name: "Test Creator",
  phone_number: "9876543210",
  creator_status: :approved,
  bio: "I'm a test creator for end-to-end testing.",
  location: "Mumbai, Maharashtra",
  niches: "Tech, Lifestyle",
  rating: 0,
  videos_completed: 0,
  price_per_video: 3000,
  wallet_balance: 0
)

puts "  ✅ Creator account created"

# ============================================
# SUMMARY
# ============================================
puts ""
puts "=" * 50
puts "🎉 SEED COMPLETE!"
puts "=" * 50
puts ""
puts "📧 Test Accounts:"
puts ""
puts "BRAND LOGIN:"
puts "  Email: brand@flikk.com"
puts "  Password: 12345678"
puts "  Wallet: ₹0"
puts ""
puts "CREATOR LOGIN:"
puts "  Email: creator@flikk.com"
puts "  Password: 12345678"
puts "  Wallet: ₹0"
puts ""
puts "📊 Data Summary:"
puts "  - #{User.where(role: 'brand').count} Brand"
puts "  - #{User.where(role: 'creator').count} Creator"
puts "  - #{Campaign.count} Campaigns"
puts "  - #{Submission.count} Submissions"
puts "  - #{WalletTransaction.count} Wallet Transactions"
puts ""
puts "Ready for end-to-end testing! 🚀"
puts ""
