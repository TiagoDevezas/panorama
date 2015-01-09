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

ActiveRecord::Schema.define(version: 20150108141909) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "articles", force: true do |t|
    t.string   "title"
    t.text     "url"
    t.datetime "pub_date"
    t.integer  "feed_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "twitter_shares"
    t.integer  "facebook_shares"
    t.text     "summary"
  end

  add_index "articles", ["feed_id"], name: "index_articles_on_feed_id", using: :btree

  create_table "articles_cats", id: false, force: true do |t|
    t.integer "article_id"
    t.integer "cat_id"
  end

  add_index "articles_cats", ["article_id", "cat_id"], name: "index_articles_cats_on_article_id_and_cat_id", unique: true, using: :btree

  create_table "cats", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "feeds", force: true do |t|
    t.string   "name"
    t.string   "url"
    t.integer  "source_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "last_modified"
    t.datetime "last_crawled"
  end

  add_index "feeds", ["source_id"], name: "index_feeds_on_source_id", using: :btree

  create_table "sources", force: true do |t|
    t.string   "name"
    t.string   "url"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "source_type"
    t.string   "acronym"
  end

end
