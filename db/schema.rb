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

ActiveRecord::Schema[8.1].define(version: 2026_05_17_180836) do
  create_table "boss_keys", force: :cascade do |t|
    t.integer "access_level", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "deleted_at"
    t.integer "holder_id", null: false
    t.string "type", null: false
    t.datetime "updated_at", null: false
    t.index ["access_level"], name: "index_boss_keys_on_access_level"
    t.index ["deleted_at"], name: "index_boss_keys_on_deleted_at"
    t.index ["holder_id", "type"], name: "index_boss_keys_on_holder_id_and_type", unique: true
    t.index ["holder_id"], name: "index_boss_keys_on_holder_id"
    t.index ["type"], name: "index_boss_keys_on_type"
  end

  create_table "characters", force: :cascade do |t|
    t.string "contact_address", limit: 4096, null: false
    t.datetime "created_at", null: false
    t.datetime "deleted_at"
    t.string "tag", limit: 4096, null: false
    t.datetime "updated_at", null: false
    t.index ["contact_address"], name: "index_characters_on_contact_address", unique: true
    t.index ["deleted_at"], name: "index_characters_on_deleted_at"
    t.index ["tag"], name: "index_characters_on_tag", unique: true
  end

  create_table "padlock_invitations", force: :cascade do |t|
    t.integer "carrier_id"
    t.datetime "created_at", null: false
    t.datetime "expires_at", null: false
    t.integer "issuer_id", null: false
    t.string "key", null: false
    t.datetime "last_unlocked_at"
    t.datetime "updated_at", null: false
    t.index ["carrier_id"], name: "index_padlock_invitations_on_carrier_id"
    t.index ["expires_at"], name: "index_padlock_invitations_on_expires_at"
    t.index ["issuer_id"], name: "index_padlock_invitations_on_issuer_id"
    t.index ["key"], name: "index_padlock_invitations_on_key", unique: true
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
    t.datetime "expires_at"
    t.string "ip_address"
    t.string "token", null: false
    t.datetime "updated_at", null: false
    t.string "user_agent"
    t.index ["character_id"], name: "index_sessions_on_character_id"
    t.index ["expires_at"], name: "index_sessions_on_expires_at"
    t.index ["token"], name: "sessions_token", unique: true
  end

  add_foreign_key "boss_keys", "characters", column: "holder_id"
  add_foreign_key "padlock_invitations", "characters", column: "carrier_id"
  add_foreign_key "padlock_invitations", "characters", column: "issuer_id"
  add_foreign_key "padlock_passwords", "characters"
  add_foreign_key "padlock_passwords", "padlock_passwords", column: "replacement_padlock_id"
  add_foreign_key "sessions", "characters"
end
