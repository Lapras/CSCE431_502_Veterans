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

ActiveRecord::Schema[7.2].define(version: 2025_10_18_031427) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "attendances", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "event_id", null: false
    t.string "status", default: "pending", null: false
    t.datetime "checked_in_at"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["event_id"], name: "index_attendances_on_event_id"
    t.index ["user_id", "event_id"], name: "index_attendances_on_user_id_and_event_id", unique: true
    t.index ["user_id"], name: "index_attendances_on_user_id"
  end

  create_table "approvals", force: :cascade do |t|
    t.bigint "excusal_request_id", null: false
    t.bigint "approved_by_user_id", null: false
    t.string "decision", null: false
    t.datetime "decision_at", precision: nil, null: false
    t.text "comment"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["approved_by_user_id"], name: "index_approvals_on_approved_by_user_id"
    t.index ["excusal_request_id", "decision"], name: "index_approvals_on_excusal_request_id_and_decision"
    t.index ["excusal_request_id"], name: "index_approvals_on_excusal_request_id"
  end

  create_table "events", force: :cascade do |t|
    t.string "title"
    t.datetime "starts_at"
    t.string "location"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "excusal_requests", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "event_id", null: false
    t.text "reason"
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["event_id"], name: "index_excusal_requests_on_event_id"
    t.index ["user_id"], name: "index_excusal_requests_on_user_id"
  end

  create_table "recurring_approvals", force: :cascade do |t|
    t.bigint "recurring_excusal_id", null: false
    t.bigint "approved_by_user_id", null: false
    t.string "decision", null: false
    t.datetime "decision_at", precision: nil, null: false
    t.text "comment"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["approved_by_user_id"], name: "index_recurring_approvals_on_approved_by_user_id"
    t.index ["recurring_excusal_id", "decision"], name: "index_recurring_approvals_on_recurring_excusal_id_and_decision"
    t.index ["recurring_excusal_id"], name: "index_recurring_approvals_on_recurring_excusal_id"
  end

  create_table "recurring_excusals", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "recurring_days"
    t.time "recurring_start_time"
    t.time "recurring_end_time"
    t.text "reason"
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_recurring_excusals_on_user_id"
  end

  create_table "roles", force: :cascade do |t|
    t.string "name"
    t.string "resource_type"
    t.bigint "resource_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name", "resource_type", "resource_id"], name: "index_roles_on_name_and_resource_type_and_resource_id"
    t.index ["resource_type", "resource_id"], name: "index_roles_on_resource"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", null: false
    t.string "full_name"
    t.string "uid"
    t.string "avatar_url"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  create_table "users_roles", id: false, force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "role_id"
    t.index ["role_id"], name: "index_users_roles_on_role_id"
    t.index ["user_id", "role_id"], name: "index_users_roles_on_user_id_and_role_id"
    t.index ["user_id"], name: "index_users_roles_on_user_id"
  end

  add_foreign_key "approvals", "excusal_requests"
  add_foreign_key "approvals", "users", column: "approved_by_user_id"
  add_foreign_key "attendances", "events"
  add_foreign_key "attendances", "users"
  add_foreign_key "excusal_requests", "events"
  add_foreign_key "excusal_requests", "users"
  add_foreign_key "recurring_approvals", "recurring_excusals"
  add_foreign_key "recurring_approvals", "users", column: "approved_by_user_id"
  add_foreign_key "recurring_excusals", "users"
end
