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

ActiveRecord::Schema[8.1].define(version: 2026_01_23_044529) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "branches", force: :cascade do |t|
    t.boolean "active", default: true
    t.string "address"
    t.datetime "created_at", null: false
    t.string "email"
    t.decimal "latitude"
    t.decimal "longitude"
    t.string "name"
    t.string "phone"
    t.bigint "studio_id", null: false
    t.string "timezone"
    t.datetime "updated_at", null: false
    t.index ["studio_id"], name: "index_branches_on_studio_id"
  end

  create_table "companies", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "description"
    t.string "name"
    t.datetime "updated_at", null: false
  end

  create_table "company_users", force: :cascade do |t|
    t.bigint "company_id", null: false
    t.datetime "created_at", null: false
    t.integer "role", default: 0, null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["company_id"], name: "index_company_users_on_company_id"
    t.index ["user_id", "company_id"], name: "index_company_users_on_user_id_and_company_id", unique: true
    t.index ["user_id"], name: "index_company_users_on_user_id"
  end

  create_table "digital_channels", force: :cascade do |t|
    t.integer "channel_type", null: false
    t.datetime "created_at", null: false
    t.bigint "studio_id", null: false
    t.datetime "updated_at", null: false
    t.string "value", null: false
    t.index ["studio_id"], name: "index_digital_channels_on_studio_id"
  end

  create_table "jwt_denylists", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "exp"
    t.string "jti"
    t.datetime "updated_at", null: false
    t.index ["jti"], name: "index_jwt_denylists_on_jti"
  end

  create_table "rooms", force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.bigint "branch_id", null: false
    t.integer "capacity", null: false
    t.datetime "created_at", null: false
    t.jsonb "layout", default: {}, null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["branch_id"], name: "index_rooms_on_branch_id"
  end

  create_table "schedules", force: :cascade do |t|
    t.boolean "active", default: true
    t.bigint "branch_id", null: false
    t.datetime "created_at", null: false
    t.integer "day_of_week", null: false
    t.time "end_time", null: false
    t.time "start_time", null: false
    t.datetime "updated_at", null: false
    t.index ["branch_id", "day_of_week", "start_time", "end_time"], name: "idx_on_branch_id_day_of_week_start_time_end_time_add335bba2", unique: true
    t.index ["branch_id"], name: "index_schedules_on_branch_id"
  end

  create_table "studios", force: :cascade do |t|
    t.bigint "company_id", null: false
    t.datetime "created_at", null: false
    t.string "description"
    t.string "handle", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id"], name: "index_studios_on_company_id"
    t.index ["handle"], name: "index_studios_on_handle", unique: true
  end

  create_table "user_profiles", force: :cascade do |t|
    t.date "birth_date"
    t.datetime "created_at", null: false
    t.integer "gender", default: 0, null: false
    t.string "last_name", null: false
    t.string "name", null: false
    t.string "second_last_name"
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.index ["user_id"], name: "index_user_profiles_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "current_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.integer "failed_attempts", default: 0, null: false
    t.datetime "last_sign_in_at"
    t.string "last_sign_in_ip"
    t.datetime "locked_at"
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.integer "sign_in_count", default: 0, null: false
    t.string "unlock_token"
    t.datetime "updated_at", null: false
    t.string "verification_code"
    t.datetime "verification_sent_at"
    t.boolean "verified", default: false
    t.datetime "verified_at"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["unlock_token"], name: "index_users_on_unlock_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "branches", "studios"
  add_foreign_key "company_users", "companies"
  add_foreign_key "company_users", "users"
  add_foreign_key "digital_channels", "studios"
  add_foreign_key "rooms", "branches"
  add_foreign_key "schedules", "branches"
  add_foreign_key "studios", "companies"
  add_foreign_key "user_profiles", "users", on_delete: :cascade
end
