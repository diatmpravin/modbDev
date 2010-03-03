# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20100302195730) do

  create_table "accounts", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "setup_status",                                                    :default => 1
    t.boolean  "accept_terms",                                                    :default => false
    t.boolean  "accept_offers",                                                   :default => false
    t.date     "today"
    t.integer  "number"
    t.string   "name",                :limit => 50
    t.integer  "parent_id"
    t.boolean  "reseller",                                                        :default => false
    t.boolean  "can_assign_reseller",                                             :default => false
    t.string   "phone_number",        :limit => 10
    t.string   "address1"
    t.string   "address2"
    t.string   "city"
    t.string   "state"
    t.string   "zip"
    t.decimal  "monthly_unit_price",                :precision => 6, :scale => 2
    t.boolean  "delta",                                                           :default => true,  :null => false
    t.integer  "lft"
    t.integer  "rgt"
  end

  add_index "accounts", ["parent_id"], :name => "index_accounts_on_parent_id"

  create_table "alert_recipients", :force => true do |t|
    t.integer  "account_id"
    t.integer  "recipient_type"
    t.string   "email",          :limit => 50
    t.string   "phone_number",   :limit => 10
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "phone_carrier",  :limit => 30
  end

  add_index "alert_recipients", ["account_id"], :name => "index_alert_recipients_on_account_id"

  create_table "device_alert_recipients", :force => true do |t|
    t.integer  "device_id"
    t.integer  "alert_recipient_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "device_geofences", :force => true do |t|
    t.integer  "device_id"
    t.integer  "geofence_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "device_geofences", ["device_id"], :name => "index_device_geofences_on_device_id"
  add_index "device_geofences", ["geofence_id"], :name => "index_device_geofences_on_geofence_id"

  create_table "device_profiles", :force => true do |t|
    t.integer  "account_id"
    t.boolean  "alert_on_speed",                     :default => false
    t.integer  "speed_threshold",                    :default => 70
    t.boolean  "alert_on_aggressive",                :default => false
    t.integer  "rpm_threshold",                      :default => 5000
    t.boolean  "alert_on_idle",                      :default => false
    t.integer  "idle_threshold",                     :default => 5
    t.boolean  "alert_on_after_hours",               :default => false
    t.integer  "after_hours_start",                  :default => 79200
    t.integer  "after_hours_end",                    :default => 21600
    t.string   "time_zone",            :limit => 64, :default => "Eastern Time (US & Canada)"
    t.boolean  "detect_pitstops",                    :default => false
    t.integer  "pitstop_threshold",                  :default => 10
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name",                 :limit => 30
    t.boolean  "alert_on_reset"
  end

  create_table "device_tags", :force => true do |t|
    t.integer  "device_id"
    t.integer  "tag_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "devices", :force => true do |t|
    t.integer  "account_id"
    t.string   "name",                 :limit => 30
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "color_id",                           :default => 0
    t.string   "fw_version",           :limit => 32
    t.string   "obd_fw_version",       :limit => 32
    t.string   "profile",              :limit => 16
    t.string   "vin_number",           :limit => 17
    t.string   "reported_vin_number",  :limit => 17
    t.integer  "speed_threshold",                    :default => 70
    t.boolean  "alert_on_speed",                     :default => false
    t.integer  "rpm_threshold",                      :default => 5000
    t.boolean  "alert_on_aggressive",                :default => false
    t.boolean  "alert_on_idle",                      :default => false
    t.boolean  "alert_on_after_hours",               :default => false
    t.integer  "idle_threshold",                     :default => 5
    t.integer  "after_hours_start",                  :default => 79200
    t.integer  "after_hours_end",                    :default => 21600
    t.integer  "tracker_id"
    t.boolean  "to_be_deleted"
    t.integer  "odometer"
    t.integer  "user_id"
    t.string   "time_zone",            :limit => 64, :default => "Eastern Time (US & Canada)"
    t.boolean  "detect_pitstops",                    :default => false
    t.integer  "pitstop_threshold",                  :default => 10
    t.boolean  "delta",                              :default => true,                         :null => false
    t.integer  "device_profile_id"
    t.boolean  "lock_vin",                           :default => false
    t.boolean  "alert_on_reset",                     :default => false
  end

  add_index "devices", ["account_id"], :name => "index_devices_on_account_id"
  add_index "devices", ["delta"], :name => "index_devices_on_delta"
  add_index "devices", ["tracker_id"], :name => "index_devices_on_tracker_id"
  add_index "devices", ["user_id"], :name => "index_devices_on_user_id"

  create_table "events", :force => true do |t|
    t.integer  "point_id"
    t.integer  "event_type"
    t.string   "geofence_name"
    t.integer  "speed_threshold"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "occurred_at"
  end

  add_index "events", ["point_id"], :name => "index_events_on_point_id"

  create_table "geofence_alert_recipients", :force => true do |t|
    t.integer  "geofence_id"
    t.integer  "alert_recipient_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "geofence_device_groups", :id => false, :force => true do |t|
    t.integer "geofence_id"
    t.integer "group_id"
  end

  create_table "geofences", :force => true do |t|
    t.integer  "geofence_type"
    t.text     "coordinates"
    t.integer  "radius"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "account_id"
    t.string   "name",           :limit => 30
    t.boolean  "alert_on_exit",                :default => false
    t.boolean  "alert_on_entry",               :default => false
    t.boolean  "delta",                        :default => true
  end

  add_index "geofences", ["account_id"], :name => "index_geofences_on_account_id"

  create_table "group_links", :id => false, :force => true do |t|
    t.integer "group_id"
    t.integer "link_id"
  end

  create_table "groups", :force => true do |t|
    t.integer  "account_id"
    t.string   "name"
    t.string   "of"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "delta",      :default => true
    t.integer  "parent_id"
    t.integer  "lft"
    t.integer  "rgt"
  end

  create_table "landmarks", :force => true do |t|
    t.integer  "account_id"
    t.decimal  "latitude",                 :precision => 8, :scale => 5
    t.decimal  "longitude",                :precision => 8, :scale => 5
    t.integer  "radius",                                                 :default => 100
    t.string   "name",       :limit => 30
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "delta",                                                  :default => true, :null => false
  end

  add_index "landmarks", ["account_id"], :name => "index_landmarks_on_account_id"

  create_table "legs", :force => true do |t|
    t.integer  "trip_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "start"
    t.datetime "finish"
    t.integer  "miles",                                     :default => 0
    t.integer  "idle_time",                                 :default => 0
    t.decimal  "average_mpg", :precision => 4, :scale => 1, :default => 0.0
  end

  add_index "legs", ["trip_id"], :name => "index_legs_on_trip_id"

  create_table "phone_devices", :force => true do |t|
    t.integer  "phone_id"
    t.integer  "device_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "phones", :force => true do |t|
    t.integer  "account_id"
    t.string   "name",            :limit => 30
    t.string   "moshi_key",       :limit => 32
    t.integer  "request_id",                    :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "activation_code", :limit => 8
  end

  add_index "phones", ["account_id"], :name => "index_phones_on_account_id"

  create_table "points", :force => true do |t|
    t.integer  "event"
    t.datetime "occurred_at"
    t.decimal  "latitude",     :precision => 8, :scale => 5
    t.decimal  "longitude",    :precision => 8, :scale => 5
    t.integer  "altitude"
    t.integer  "speed"
    t.boolean  "accelerating"
    t.boolean  "decelerating"
    t.integer  "rpm"
    t.integer  "heading"
    t.integer  "satellites"
    t.decimal  "hdop",         :precision => 4, :scale => 2
    t.integer  "miles"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "leg_id"
    t.integer  "device_id"
    t.decimal  "mpg",          :precision => 4, :scale => 1, :default => 0.0
    t.decimal  "battery",      :precision => 3, :scale => 1
    t.integer  "signal"
    t.boolean  "locked"
    t.integer  "duration"
  end

  add_index "points", ["device_id"], :name => "index_points_on_device_id"
  add_index "points", ["leg_id"], :name => "index_points_on_leg_id"

  create_table "tags", :force => true do |t|
    t.integer  "account_id"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "tags", ["account_id"], :name => "index_tags_on_account_id"

  create_table "trackers", :force => true do |t|
    t.string   "imei_number",   :limit => 32
    t.string   "sim_number",    :limit => 32
    t.integer  "status",                      :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "msisdn_number", :limit => 32
    t.integer  "account_id"
    t.boolean  "delta",                       :default => true, :null => false
  end

  add_index "trackers", ["imei_number"], :name => "index_trackers_on_imei_number"

  create_table "trip_tags", :force => true do |t|
    t.integer  "trip_id"
    t.integer  "tag_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "trips", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "device_id"
    t.datetime "start"
    t.datetime "finish"
    t.integer  "miles",                                     :default => 0
    t.integer  "idle_time",                                 :default => 0
    t.decimal  "average_mpg", :precision => 4, :scale => 1, :default => 0.0
  end

  add_index "trips", ["device_id"], :name => "index_trips_on_device_id"

  create_table "users", :force => true do |t|
    t.integer  "account_id"
    t.string   "login",                     :limit => 30
    t.string   "crypted_password",          :limit => 40
    t.string   "salt",                      :limit => 40
    t.string   "name",                      :limit => 30
    t.string   "email",                     :limit => 50
    t.integer  "roles",                                   :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "time_zone",                 :limit => 64, :default => "Eastern Time (US & Canada)"
    t.string   "remember_token",            :limit => 40
    t.datetime "remember_token_expires_at"
    t.string   "password_reset_code",       :limit => 48
    t.boolean  "delta",                                   :default => true
    t.integer  "device_group_id"
  end

  add_index "users", ["account_id"], :name => "index_users_on_account_id"

end
