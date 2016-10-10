# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20161010160947) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "events", force: :cascade do |t|
    t.string   "name",        null: false
    t.text     "description", null: false
    t.string   "join_code",   null: false
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.integer  "user_id"
    t.index ["user_id"], name: "index_events_on_user_id", using: :btree
  end

  create_table "songs", force: :cascade do |t|
    t.string   "name",                 null: false
    t.string   "artist",               null: false
    t.string   "art",                  null: false
    t.integer  "duration",             null: false
    t.string   "uri",                  null: false
    t.integer  "score",      limit: 2, null: false
    t.integer  "event_id",             null: false
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
    t.index ["event_id"], name: "index_songs_on_event_id", using: :btree
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.index ["email"], name: "index_users_on_email", unique: true, using: :btree
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  end

  create_table "votes", force: :cascade do |t|
    t.string   "user_identifier", null: false
    t.integer  "vote",            null: false
    t.integer  "song_id",         null: false
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.index ["song_id"], name: "index_votes_on_song_id", using: :btree
  end

  add_foreign_key "events", "users"
  add_foreign_key "songs", "events"
  add_foreign_key "votes", "songs"
end
