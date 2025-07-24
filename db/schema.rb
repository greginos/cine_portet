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

ActiveRecord::Schema[8.0].define(version: 2025_07_24_112845) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "active_admin_comments", force: :cascade do |t|
    t.string "namespace"
    t.text "body"
    t.string "resource_type"
    t.bigint "resource_id"
    t.string "author_type"
    t.bigint "author_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["author_type", "author_id"], name: "index_active_admin_comments_on_author"
    t.index ["namespace"], name: "index_active_admin_comments_on_namespace"
    t.index ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource"
  end

  create_table "admin_users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_admin_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_admin_users_on_reset_password_token", unique: true
  end

  create_table "movies", force: :cascade do |t|
    t.string "title", null: false
    t.text "description"
    t.integer "duration"
    t.string "genre"
    t.jsonb "director", default: {}
    t.jsonb "cast", default: {}
    t.string "poster_url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "imdb_id"
    t.index ["genre"], name: "index_movies_on_genre"
    t.index ["imdb_id"], name: "index_movies_on_imdb_id", unique: true
    t.index ["title"], name: "index_movies_on_title"
  end

  create_table "programmation_staffs", force: :cascade do |t|
    t.bigint "programmation_id", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "role"
    t.index ["programmation_id", "user_id", "role"], name: "index_programmation_staff_unique", unique: true
    t.index ["programmation_id"], name: "index_programmation_staffs_on_programmation_id"
    t.index ["user_id"], name: "index_programmation_staffs_on_user_id"
  end

  create_table "programmations", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "imdb_id"
    t.datetime "time"
    t.integer "max_tickets"
    t.decimal "normal_price", precision: 8, scale: 2
    t.decimal "member_price", precision: 8, scale: 2
    t.decimal "reduced_price", precision: 8, scale: 2
    t.bigint "movie_id", null: false
    t.index ["imdb_id"], name: "index_programmations_on_imdb_id"
    t.index ["movie_id"], name: "index_programmations_on_movie_id"
  end

  create_table "tickets", force: :cascade do |t|
    t.bigint "programmation_id", null: false
    t.string "ticket_type", null: false
    t.decimal "price", precision: 8, scale: 2, null: false
    t.integer "quantity", default: 1, null: false
    t.string "status", default: "pending", null: false
    t.string "stripe_session_id"
    t.string "email"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["programmation_id"], name: "index_tickets_on_programmation_id"
    t.index ["status"], name: "index_tickets_on_status"
    t.index ["ticket_type"], name: "index_tickets_on_ticket_type"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "first_name"
    t.string "last_name"
    t.string "sign_in_token"
    t.datetime "token_expires_at"
    t.string "address"
    t.string "zip_code"
    t.string "city"
    t.string "country"
    t.string "phone"
    t.string "member_number"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "programmation_staffs", "programmations"
  add_foreign_key "programmation_staffs", "users"
  add_foreign_key "programmations", "movies"
  add_foreign_key "tickets", "programmations"
end
