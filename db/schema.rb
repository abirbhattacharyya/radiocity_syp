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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20120711070325) do

  create_table "offers", :force => true do |t|
    t.string   "ip"
    t.string   "response"
    t.integer  "product_id"
    t.float    "price"
    t.integer  "counter"
    t.string   "token"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "payments", :force => true do |t|
    t.integer  "offer_id"
    t.integer  "quantity"
    t.string   "transaction_id"
    t.string   "email"
    t.float    "price"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "street1"
    t.string   "street2"
    t.string   "city"
    t.string   "state"
    t.string   "country"
    t.string   "postal_code"
    t.integer  "phone",          :limit => 8
    t.integer  "cc_number",      :limit => 8
    t.string   "cc_type"
    t.integer  "cc_expiry_m",    :limit => 2
    t.integer  "cc_expiry_y",    :limit => 2
    t.datetime "created_at",                  :null => false
    t.datetime "updated_at",                  :null => false
  end

  create_table "products", :force => true do |t|
    t.integer  "user_id"
    t.string   "name"
    t.text     "description"
    t.float    "regular_price"
    t.float    "target_price"
    t.integer  "quantity"
    t.integer  "product_type"
    t.boolean  "is_live",            :default => true
    t.datetime "created_at",                           :null => false
    t.datetime "updated_at",                           :null => false
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
  end

  create_table "profiles", :force => true do |t|
    t.integer  "user_id"
    t.string   "name"
    t.text     "address"
    t.integer  "phone",             :limit => 8
    t.string   "email"
    t.string   "twitter"
    t.string   "facebook_url"
    t.string   "website"
    t.string   "header_color"
    t.datetime "created_at",                     :null => false
    t.datetime "updated_at",                     :null => false
    t.string   "logo_file_name"
    t.string   "logo_content_type"
    t.integer  "logo_file_size"
    t.datetime "logo_updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "email"
    t.string   "password"
    t.string   "remember_token"
    t.date     "remember_token_expires_at"
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
  end

end
