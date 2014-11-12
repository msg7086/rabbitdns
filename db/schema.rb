# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20141111065343) do

  create_table "cryptokeys", force: true do |t|
    t.integer "domain_id", null: false
    t.integer "flags",     null: false
    t.boolean "active"
    t.text    "content"
  end

  add_index "cryptokeys", ["domain_id"], name: "domainidindex", using: :btree

  create_table "domainmetadata", force: true do |t|
    t.integer "domain_id",            null: false
    t.string  "kind",      limit: 32
    t.text    "content"
  end

  add_index "domainmetadata", ["domain_id", "kind"], name: "domainmetadata_idx", using: :btree

  create_table "domains", force: true do |t|
    t.string  "name",                        null: false
    t.string  "master",          limit: 128
    t.integer "last_check"
    t.string  "type",            limit: 6,   null: false
    t.integer "notified_serial"
    t.string  "account",         limit: 40
    t.integer "user_id"
  end

  add_index "domains", ["name"], name: "name_index", unique: true, using: :btree
  add_index "domains", ["user_id"], name: "index_domains_on_user_id", using: :btree

  create_table "records", force: true do |t|
    t.integer "domain_id"
    t.string  "name"
    t.string  "type",        limit: 10
    t.text    "content",     limit: 16777215
    t.integer "ttl"
    t.integer "prio"
    t.integer "change_date"
    t.string  "geo"
    t.string  "geoisp"
    t.boolean "paused"
    t.boolean "disabled",                     default: false
    t.string  "ordername"
    t.boolean "auth",                         default: true
  end

  add_index "records", ["domain_id"], name: "domain_id", using: :btree
  add_index "records", ["name", "type"], name: "nametype_index", using: :btree
  add_index "records", ["name"], name: "rec_name_index", using: :btree

  create_table "supermasters", id: false, force: true do |t|
    t.string "ip",         limit: 25, null: false
    t.string "nameserver",            null: false
    t.string "account",    limit: 40
  end

  create_table "tsigkeys", force: true do |t|
    t.string "name"
    t.string "algorithm", limit: 50
    t.string "secret"
  end

  add_index "tsigkeys", ["name", "algorithm"], name: "namealgoindex", unique: true, using: :btree

  create_table "users", force: true do |t|
    t.string "name",     limit: 100, null: false
    t.string "email",                null: false
    t.string "password", limit: 44,  null: false
    t.string "salt",     limit: 8,   null: false
    t.string "passkey",  limit: 44,  null: false
  end

end
