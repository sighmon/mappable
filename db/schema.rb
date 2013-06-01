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

ActiveRecord::Schema.define(:version => 20130601064732) do

  create_table "images", :force => true do |t|
    t.float    "latitude"
    t.float    "longitude"
    t.text     "location_description"
    t.string   "fullsize_url"
    t.string   "thumbnail_url"
    t.string   "copyright"
    t.text     "caption"
    t.datetime "relevant_from"
    t.datetime "relevant_to"
    t.datetime "created_at",           :null => false
    t.datetime "updated_at",           :null => false
  end

end
