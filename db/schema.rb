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

ActiveRecord::Schema[8.1].define(version: 2026_01_27_231059) do
  create_table "characters", force: :cascade do |t|
    t.string "contact_address", limit: 4096, null: false
    t.datetime "created_at", null: false
    t.datetime "deleted_at"
    t.string "original_tag", limit: 4096, null: false
    t.string "tag", limit: 4096, null: false
    t.datetime "updated_at", null: false
    t.index ["contact_address"], name: "index_characters_on_contact_address", unique: true
    t.index ["deleted_at"], name: "index_characters_on_deleted_at"
    t.index ["tag"], name: "index_characters_on_tag", unique: true
  end

  create_table "padlock_passwords", force: :cascade do |t|
    t.integer "character_id", null: false
    t.datetime "created_at", null: false
    t.date "expires_at"
    t.string "key_digest", null: false
    t.datetime "last_unlocked_at"
    t.integer "replacement_padlock_id"
    t.integer "unlocked_by", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["character_id"], name: "index_padlock_passwords_on_character_id"
    t.index ["replacement_padlock_id"], name: "index_padlock_passwords_on_replacement_padlock_id"
  end

  create_table "sessions", force: :cascade do |t|
    t.integer "character_id", null: false
    t.datetime "created_at", null: false
    t.string "ip_address"
    t.string "token", null: false
    t.datetime "updated_at", null: false
    t.string "user_agent"
    t.index ["character_id"], name: "index_sessions_on_character_id"
    t.index ["token"], name: "sessions_token", unique: true
  end

  add_foreign_key "padlock_passwords", "characters"
  add_foreign_key "padlock_passwords", "padlock_passwords", column: "replacement_padlock_id"
  add_foreign_key "sessions", "characters"
end
