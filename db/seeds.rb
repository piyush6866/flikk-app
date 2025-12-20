# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

puts "🌱 Starting seed..."

# Clear existing data (be careful in production!)
if Rails.env.development?
  puts "🧹 Cleaning up existing data..."
  Submission.destroy_all
  Campaign.destroy_all
  User.destroy_all
end

# ============================================
# CREATE BRAND USERS
# ============================================
puts "🏢 Creating brand accounts..."

brand1 = User.create!(
  email: "brand@example.com",
  password: "password123",
  password_confirmation: "password123",
  role: "brand",
  brand_name: "Mamaearth",
)

brand2 = User.create!(
  email: "brand2@example.com",
  password: "password123",
  password_confirmation: "password123",
  role: "brand",
  brand_name: "boAt Lifestyle",
)

brand3 = User.create!(
  email: "brand3@example.com",
  password: "password123",
  password_confirmation: "password123",
  role: "brand",
  brand_name: "Sugar Cosmetics",
)

puts "  ✅ Created #{User.where(role: 'brand').count} brands"

# ============================================
# CREATE CREATOR USERS (Various Statuses)
# ============================================
puts "👤 Creating creator accounts..."

# Approved creators (can be found on Browse Creators page)
creator1 = User.create!(
  email: "creator@example.com",
  password: "password123",
  password_confirmation: "password123",
  role: "creator",
  name: "Priya Sharma",
  phone_number: "9876543210",
  creator_status: :approved,
  bio: "Hey! I'm Priya, a content creator based in Mumbai. I specialize in beauty, skincare, and lifestyle content. With 3+ years of experience creating authentic, engaging videos, I help brands connect with their audience through genuine storytelling.",
  location: "Mumbai, Maharashtra",
  niches: "Beauty, Skincare, Lifestyle",
  rating: 4.8,
  videos_completed: 47,
  price_per_video: 5000,
  instagram_handle: "priya_creates",
  youtube_handle: "PriyaCreates"
)

creator2 = User.create!(
  email: "creator2@example.com",
  password: "password123",
  password_confirmation: "password123",
  role: "creator",
  name: "Rahul Verma",
  phone_number: "9876543211",
  creator_status: :approved,
  bio: "Tech enthusiast and gadget reviewer. I create detailed, honest reviews that help viewers make informed decisions. My videos combine in-depth analysis with entertaining presentation.",
  location: "Bangalore, Karnataka",
  niches: "Tech, Gadgets, Electronics",
  rating: 4.9,
  videos_completed: 82,
  price_per_video: 7500,
  instagram_handle: "techrahul",
  youtube_handle: "TechWithRahul"
)

creator3 = User.create!(
  email: "creator3@example.com",
  password: "password123",
  password_confirmation: "password123",
  role: "creator",
  name: "Ananya Gupta",
  phone_number: "9876543212",
  creator_status: :approved,
  bio: "Fashion and lifestyle creator with a passion for sustainable fashion. I believe in authentic content that resonates with real people. Let's create something beautiful together!",
  location: "Delhi, NCR",
  niches: "Fashion, Sustainable Living, Lifestyle",
  rating: 4.7,
  videos_completed: 35,
  price_per_video: 4500,
  instagram_handle: "ananya.styles"
)

creator4 = User.create!(
  email: "creator4@example.com",
  password: "password123",
  password_confirmation: "password123",
  role: "creator",
  name: "Vikram Singh",
  phone_number: "9876543213",
  creator_status: :approved,
  bio: "Fitness enthusiast and certified personal trainer. I create workout videos, supplement reviews, and fitness content that inspires people to live healthier lives.",
  location: "Pune, Maharashtra",
  niches: "Fitness, Health, Supplements",
  rating: 4.6,
  videos_completed: 28,
  price_per_video: 4000,
  instagram_handle: "fitvik"
)

creator5 = User.create!(
  email: "creator5@example.com",
  password: "password123",
  password_confirmation: "password123",
  role: "creator",
  name: "Sneha Reddy",
  phone_number: "9876543214",
  creator_status: :approved,
  bio: "Food blogger and home chef. I create mouthwatering recipe videos and honest food product reviews. My content brings the joy of cooking to millions!",
  location: "Hyderabad, Telangana",
  niches: "Food, Cooking, Kitchen Gadgets",
  rating: 4.9,
  videos_completed: 63,
  price_per_video: 3500,
  instagram_handle: "sneha.cooks"
)

creator6 = User.create!(
  email: "creator6@example.com",
  password: "password123",
  password_confirmation: "password123",
  role: "creator",
  name: "Arjun Nair",
  phone_number: "9876543215",
  creator_status: :approved,
  bio: "Travel vlogger exploring India's hidden gems. I create immersive travel content featuring local experiences, hotels, and travel gear reviews.",
  location: "Kochi, Kerala",
  niches: "Travel, Adventure, Hotels",
  rating: 4.5,
  videos_completed: 21,
  price_per_video: 6000,
  instagram_handle: "wandering.arjun"
)

# Pending approval creators (testing the approval flow)
creator_pending1 = User.create!(
  email: "newcreator@example.com",
  password: "password123",
  password_confirmation: "password123",
  role: "creator",
  name: "Kavya Iyer",
  phone_number: "9876543216",
  creator_status: :pending_approval,
  bio: "New to UGC but passionate about skincare! Looking forward to creating authentic content.",
  location: "Chennai, Tamil Nadu",
  niches: "Skincare, Beauty",
  rating: 0,
  videos_completed: 0,
  price_per_video: 2500
)

creator_pending2 = User.create!(
  email: "newcreator2@example.com",
  password: "password123",
  password_confirmation: "password123",
  role: "creator",
  name: "Aditya Bhatt",
  phone_number: "9876543217",
  creator_status: :pending_approval,
  bio: "Gaming content creator transitioning to UGC. Experienced in video editing and storytelling.",
  location: "Jaipur, Rajasthan",
  niches: "Gaming, Tech",
  rating: 0,
  videos_completed: 0,
  price_per_video: 3000
)

puts "  ✅ Created #{User.where(role: 'creator').count} creators (#{User.approved_creators.count} approved)"

# ============================================
# CREATE CAMPAIGNS
# ============================================
puts "📢 Creating campaigns..."

campaign1 = Campaign.create!(
  user: brand1,
  title: "Onion Hair Oil Launch",
  product_name: "Mamaearth Onion Hair Oil",
  product_url: "https://mamaearth.in/product/onion-hair-oil",
  scenario: "Testimonial",
  aspect_ratio: "9:16",
  duration: 30,
  price: 5000,
  instructions: "We're launching our new Onion Hair Oil! We need authentic testimonials from creators who have struggled with hair fall.\n\n**Key Points to Cover:**\n- Show the product clearly in the first 3 seconds\n- Share your honest experience with hair fall\n- Demonstrate applying the oil\n- Mention key ingredients (Onion & Redensyl)\n- Include a call-to-action at the end\n\n**Don't:**\n- Make medical claims\n- Compare with other brands\n- Use any filters that distort the product",
  status: :live
)

campaign2 = Campaign.create!(
  user: brand1,
  title: "Vitamin C Face Serum Unboxing",
  product_name: "Mamaearth Vitamin C Face Serum",
  product_url: "https://mamaearth.in/product/vitamin-c-serum",
  scenario: "Unboxing",
  aspect_ratio: "9:16",
  duration: 45,
  price: 4000,
  instructions: "Create an exciting unboxing video for our bestselling Vitamin C Face Serum.\n\n**Requirements:**\n- Show genuine excitement\n- Highlight the packaging\n- Read out ingredients\n- Show first application\n- Good lighting is essential!",
  status: :live
)

campaign3 = Campaign.create!(
  user: brand2,
  title: "Airdopes 141 Review",
  product_name: "boAt Airdopes 141",
  product_url: "https://www.boat-lifestyle.com/products/airdopes-141",
  scenario: "How-to",
  aspect_ratio: "9:16",
  duration: 60,
  price: 7500,
  instructions: "Create a detailed review of our Airdopes 141.\n\n**Cover These Points:**\n- Unboxing and first impressions\n- Pairing process with phone\n- Sound quality test\n- Battery life experience\n- Comfort during workouts\n\n**Style:** Casual, authentic, relatable",
  status: :live
)

campaign4 = Campaign.create!(
  user: brand2,
  title: "Rockerz 450 Lifestyle Video",
  product_name: "boAt Rockerz 450",
  product_url: "https://www.boat-lifestyle.com/products/rockerz-450",
  scenario: "Lifestyle",
  aspect_ratio: "9:16",
  duration: 30,
  price: 6000,
  instructions: "Show our Rockerz 450 headphones as part of your daily lifestyle.\n\n**Ideas:**\n- Morning workout\n- Commute to work\n- Work from home setup\n- Gaming session\n\n**Vibe:** Energetic, young, aspirational",
  status: :live
)

campaign5 = Campaign.create!(
  user: brand3,
  title: "Matte Attack Lipstick Try-On",
  product_name: "Sugar Matte Attack Lipstick",
  product_url: "https://sugarcosmetics.com/products/matte-attack-lipstick",
  scenario: "Testimonial",
  aspect_ratio: "9:16",
  duration: 45,
  price: 5500,
  instructions: "Create a lip swatch and review video for our Matte Attack Lipstick range.\n\n**Show:**\n- Multiple shade swatches\n- Application technique\n- Transfer test\n- Longevity throughout the day\n\n**Target:** Young women 18-30 who love bold makeup",
  status: :live
)

campaign6 = Campaign.create!(
  user: brand3,
  title: "Ace of Face Foundation Review",
  product_name: "Sugar Ace of Face Foundation",
  product_url: "https://sugarcosmetics.com/products/ace-of-face-foundation",
  scenario: "How-to",
  aspect_ratio: "1:1",
  duration: 60,
  price: 8000,
  instructions: "Create a detailed foundation review and application tutorial.\n\n**Include:**\n- Shade matching\n- Coverage test\n- Blending technique\n- Before/after\n- 8-hour wear test\n\n**Quality:** Professional makeup content",
  status: :live
)

# A draft campaign (won't show in marketplace)
campaign_draft = Campaign.create!(
  user: brand1,
  title: "New Product Launch (TBD)",
  product_name: "Coming Soon Product",
  product_url: "https://mamaearth.in",
  scenario: "Unboxing",
  aspect_ratio: "9:16",
  duration: 30,
  price: 5000,
  instructions: "Draft - details to be finalized",
  status: :draft
)

puts "  ✅ Created #{Campaign.count} campaigns (#{Campaign.active.count} live)"

# ============================================
# CREATE SUBMISSIONS (Various States)
# ============================================
puts "📝 Creating submissions..."

# Submission 1: Applied - waiting for brand approval
sub1 = Submission.create!(
  campaign: campaign1,
  user: creator1,
  status: :applied,
  payout_amount: campaign1.price
)

# Submission 2: Approved to upload - creator can now upload
sub2 = Submission.create!(
  campaign: campaign2,
  user: creator1,
  status: :approved_to_upload,
  payout_amount: campaign2.price
)

# Submission 3: Uploaded - waiting for brand review
sub3 = Submission.create!(
  campaign: campaign3,
  user: creator2,
  status: :uploaded,
  payout_amount: campaign3.price,
  external_link: "https://drive.google.com/file/d/example123/view"
)

# Submission 4: Content approved - waiting for payment
sub4 = Submission.create!(
  campaign: campaign4,
  user: creator2,
  status: :content_approved,
  payout_amount: campaign4.price,
  approved_at: 2.days.ago,
  external_link: "https://drive.google.com/file/d/example456/view"
)

# Submission 5: Paid - complete!
sub5 = Submission.create!(
  campaign: campaign5,
  user: creator3,
  status: :paid,
  payout_amount: campaign5.price,
  approved_at: 5.days.ago,
  paid_at: 3.days.ago,
  external_link: "https://drive.google.com/file/d/example789/view"
)

# Submission 6: Revision requested - creator needs to re-upload
sub6 = Submission.create!(
  campaign: campaign6,
  user: creator3,
  status: :revision_requested,
  payout_amount: campaign6.price,
  brand_feedback: "The lighting is a bit too dark and the product isn't clearly visible in the first few seconds. Could you reshoot with better lighting and make sure the foundation bottle is shown prominently at the start?",
  revision_count: 1
)

# Submission 7: Applied by another creator
sub7 = Submission.create!(
  campaign: campaign1,
  user: creator4,
  status: :applied,
  payout_amount: campaign1.price
)

# Submission 8: Approved to upload for another campaign
sub8 = Submission.create!(
  campaign: campaign5,
  user: creator5,
  status: :approved_to_upload,
  payout_amount: campaign5.price
)

puts "  ✅ Created #{Submission.count} submissions"
puts "     - #{Submission.pending_approval.count} pending approval"
puts "     - #{Submission.ready_to_upload.count} ready to upload"
puts "     - #{Submission.under_review.count} under review"
puts "     - #{Submission.completed.count} completed"

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
puts "  Email: brand@example.com"
puts "  Password: password123"
puts ""
puts "CREATOR LOGIN:"
puts "  Email: creator@example.com"
puts "  Password: password123"
puts ""
puts "📊 Data Summary:"
puts "  - #{User.where(role: 'brand').count} Brands"
puts "  - #{User.where(role: 'creator').count} Creators (#{User.approved_creators.count} approved)"
puts "  - #{Campaign.count} Campaigns (#{Campaign.active.count} live)"
puts "  - #{Submission.count} Submissions"
puts ""
