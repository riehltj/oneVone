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

ActiveRecord::Schema[8.1].define(version: 2026_02_20_203306) do
  create_table "availabilities", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "day_of_week"
    t.time "end_time"
    t.time "start_time"
    t.string "timezone"
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["user_id"], name: "index_availabilities_on_user_id"
  end

  create_table "league_memberships", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.decimal "dupr_rating", precision: 3, scale: 1
    t.integer "league_id", null: false
    t.string "status", default: "active", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["league_id"], name: "index_league_memberships_on_league_id"
    t.index ["user_id", "league_id"], name: "index_league_memberships_on_user_id_and_league_id", unique: true
    t.index ["user_id"], name: "index_league_memberships_on_user_id"
  end

  create_table "leagues", force: :cascade do |t|
    t.string "city"
    t.datetime "created_at", null: false
    t.integer "monthly_price_cents"
    t.string "name"
    t.string "prize_description"
    t.decimal "rating_max", precision: 3, scale: 1
    t.decimal "rating_min", precision: 3, scale: 1
    t.string "region"
    t.datetime "updated_at", null: false
  end

  create_table "matches", force: :cascade do |t|
    t.integer "challenger_id", null: false
    t.datetime "created_at", null: false
    t.integer "league_id", null: false
    t.string "location"
    t.integer "opponent_id", null: false
    t.datetime "reminder_sent_at"
    t.datetime "scheduled_at"
    t.string "score"
    t.string "status", default: "pending", null: false
    t.datetime "updated_at", null: false
    t.integer "winner_id"
    t.index ["challenger_id"], name: "index_matches_on_challenger_id"
    t.index ["league_id"], name: "index_matches_on_league_id"
    t.index ["opponent_id"], name: "index_matches_on_opponent_id"
    t.index ["winner_id"], name: "index_matches_on_winner_id"
  end

  create_table "payment_subscriptions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "league_id", null: false
    t.string "status", default: "active", null: false
    t.string "stripe_subscription_id"
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["league_id"], name: "index_payment_subscriptions_on_league_id"
    t.index ["user_id", "league_id"], name: "index_payment_subscriptions_on_user_id_and_league_id", unique: true
    t.index ["user_id"], name: "index_payment_subscriptions_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.boolean "can_host", default: false, null: false
    t.datetime "created_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "name"
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.datetime "updated_at", null: false
    t.string "zone"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "availabilities", "users"
  add_foreign_key "league_memberships", "leagues"
  add_foreign_key "league_memberships", "users"
  add_foreign_key "matches", "leagues"
  add_foreign_key "matches", "users", column: "challenger_id"
  add_foreign_key "matches", "users", column: "opponent_id"
  add_foreign_key "matches", "users", column: "winner_id"
  add_foreign_key "payment_subscriptions", "leagues"
  add_foreign_key "payment_subscriptions", "users"
end
