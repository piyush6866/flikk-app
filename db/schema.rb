# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.1].define(version: 2025_12_20_010155) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "campaigns", force: :cascade do |t|
    t.string "title", null: false
    t.string "product_name", null: false
    t.string "product_url"
    t.string "scenario", null: false
    t.string "aspect_ratio", null: false
    t.integer "duration", default: 30, null: false
    t.integer "price", null: false
    t.text "instructions"
    t.integer "status", default: 1, null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["scenario"], name: "index_campaigns_on_scenario"
    t.index ["status"], name: "index_campaigns_on_status"
    t.index ["user_id"], name: "index_campaigns_on_user_id"
  end

  create_table "submissions", force: :cascade do |t|
    t.bigint "campaign_id", null: false
    t.bigint "user_id", null: false
    t.string "external_link"
    t.integer "status", default: 0, null: false
    t.integer "payout_amount", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "brand_feedback"
    t.integer "creator_net_payout", default: 0
    t.integer "brand_total_cost", default: 0
    t.integer "platform_fee_creator", default: 0
    t.integer "platform_fee_brand", default: 0
    t.datetime "approved_at"
    t.datetime "paid_at"
    t.integer "revision_count", default: 0
    t.index ["campaign_id", "user_id"], name: "index_submissions_on_campaign_id_and_user_id", unique: true
    t.index ["campaign_id"], name: "index_submissions_on_campaign_id"
    t.index ["user_id"], name: "index_submissions_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "role"
    t.string "brand_name"
    t.string "name"
    t.string "phone_number"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "bio"
    t.string "location"
    t.string "intro_video_url"
    t.string "instagram_handle"
    t.string "youtube_handle"
    t.integer "creator_status", default: 0
    t.string "niches"
    t.decimal "rating", precision: 3, scale: 2, default: "0.0"
    t.integer "videos_completed", default: 0
    t.integer "price_per_video", default: 2500
    t.integer "wallet_balance", default: 0
    t.index ["creator_status"], name: "index_users_on_creator_status"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "wallet_transactions", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.integer "amount", null: false
    t.integer "transaction_type", default: 0, null: false
    t.string "description"
    t.bigint "related_submission_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["related_submission_id"], name: "index_wallet_transactions_on_related_submission_id"
    t.index ["user_id", "created_at"], name: "index_wallet_transactions_on_user_id_and_created_at"
    t.index ["user_id"], name: "index_wallet_transactions_on_user_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "campaigns", "users"
  add_foreign_key "submissions", "campaigns"
  add_foreign_key "submissions", "users"
  add_foreign_key "wallet_transactions", "submissions", column: "related_submission_id"
  add_foreign_key "wallet_transactions", "users"
end
