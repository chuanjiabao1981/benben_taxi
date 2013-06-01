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

ActiveRecord::Schema.define(version: 20130601072535) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "postgis"

  create_table "driver_track_points", force: true do |t|
    t.integer  "driver_id"
    t.string   "mobile"
    t.spatial  "location",   limit: {:srid=>4326, :type=>"point", :geographic=>true}
    t.float    "radius"
    t.string   "coortype"
    t.integer  "tenant_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "driver_track_points", ["location"], :name => "index_driver_track_points_on_location", :spatial => true
  add_index "driver_track_points", ["tenant_id"], :name => "index_driver_track_points_on_tenant_id"

  create_table "taxi_requests", force: true do |t|
    t.string   "state"
    t.integer  "lock_version"
    t.integer  "passenger_id"
    t.string   "passenger_voice"
    t.string   "passenger_mobile"
    t.spatial  "passenger_location",     limit: {:srid=>4326, :type=>"point", :geographic=>true}
    t.datetime "timeout"
    t.integer  "driver_id"
    t.string   "driver_mobile"
    t.spatial  "driver_location",        limit: {:srid=>4326, :type=>"point", :geographic=>true}
    t.datetime "driver_response_time"
    t.integer  "tenant_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "passenger_cancel_time"
    t.datetime "passenger_confirm_time"
  end

  add_index "taxi_requests", ["passenger_location"], :name => "index_taxi_requests_on_passenger_location", :spatial => true
  add_index "taxi_requests", ["state"], :name => "index_taxi_requests_on_state"
  add_index "taxi_requests", ["tenant_id"], :name => "index_taxi_requests_on_tenant_id"
  add_index "taxi_requests", ["timeout"], :name => "index_taxi_requests_on_timeout"

  create_table "tenants", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "tenants", ["name"], :name => "index_tenants_on_name"

  create_table "users", force: true do |t|
    t.string  "name"
    t.string  "mobile"
    t.string  "account"
    t.string  "role"
    t.integer "tenant_id"
    t.string  "status"
    t.string  "password_digest"
    t.string  "remember_token"
  end

  add_index "users", ["account"], :name => "index_users_on_account"
  add_index "users", ["mobile"], :name => "index_users_on_mobile"
  add_index "users", ["remember_token"], :name => "index_users_on_remember_token"
  add_index "users", ["tenant_id"], :name => "index_users_on_tenant_id"

end
