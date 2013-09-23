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

ActiveRecord::Schema.define(version: 20130923015039) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "postgis"

  create_table "advertisements", force: true do |t|
    t.text     "content"
    t.datetime "start_time"
    t.datetime "end_time"
    t.integer  "tenant_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "advertisements", ["end_time"], :name => "index_advertisements_on_end_time"
  add_index "advertisements", ["start_time"], :name => "index_advertisements_on_start_time"

  create_table "client_exceptions", force: true do |t|
    t.string   "client_version"
    t.string   "android_version"
    t.string   "ios_version"
    t.text     "content"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "md5"
    t.integer  "num",             default: 1
  end

  add_index "client_exceptions", ["md5"], :name => "index_client_exceptions_on_md5"

  create_table "comments", force: true do |t|
    t.integer  "author_id"
    t.string   "author_role"
    t.integer  "target_id"
    t.string   "target_role"
    t.text     "content"
    t.integer  "commentable_id"
    t.string   "commentable_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "delayed_jobs", force: true do |t|
    t.integer  "priority",   default: 0, null: false
    t.integer  "attempts",   default: 0, null: false
    t.text     "handler",                null: false
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], :name => "delayed_jobs_priority"

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

  add_index "driver_track_points", ["created_at"], :name => "index_driver_track_points_on_created_at"
  add_index "driver_track_points", ["driver_id"], :name => "index_driver_track_points_on_driver_id"
  add_index "driver_track_points", ["location"], :name => "index_driver_track_points_on_location", :spatial => true
  add_index "driver_track_points", ["tenant_id"], :name => "index_driver_track_points_on_tenant_id"

  create_table "register_verifications", force: true do |t|
    t.string   "mobile"
    t.datetime "delivered_time"
    t.string   "status"
    t.string   "code"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "sms_gate_ret_raw_msg"
  end

  add_index "register_verifications", ["mobile", "code"], :name => "verification_index"

  create_table "taxi_companies", force: true do |t|
    t.string   "name"
    t.string   "boss"
    t.integer  "tenant_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

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
    t.integer  "passenger_score",                                                                 default: 5
    t.integer  "driver_score",                                                                    default: 5
    t.datetime "passenger_score_time"
    t.datetime "driver_score_time"
    t.string   "source"
    t.string   "destination"
    t.string   "plate"
    t.string   "driver_name"
  end

  add_index "taxi_requests", ["created_at"], :name => "index_taxi_requests_on_created_at"
  add_index "taxi_requests", ["driver_id"], :name => "index_taxi_requests_on_driver_id"
  add_index "taxi_requests", ["passenger_id"], :name => "index_taxi_requests_on_passenger_id"
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
    t.string   "name"
    t.string   "mobile"
    t.string   "account"
    t.string   "role"
    t.integer  "tenant_id"
    t.string   "status"
    t.string   "password_digest"
    t.string   "remember_token"
    t.string   "plate"
    t.integer  "taxi_company_id"
    t.string   "register_info"
    t.integer  "success_taxi_requests", default: 0
    t.string   "verify_code"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["account"], :name => "index_users_on_account"
  add_index "users", ["mobile"], :name => "index_users_on_mobile"
  add_index "users", ["remember_token"], :name => "index_users_on_remember_token"
  add_index "users", ["tenant_id"], :name => "index_users_on_tenant_id"

end
