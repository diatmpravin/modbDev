class Device < ActiveRecord::Base

  ##
  # Sphinx Index Definitions
  ##
  define_index do
    indexes :name, :sortable => true
    indexes :obd_fw_version,          :as => :firmware_version
    indexes :vin_number,              :as => :vin
    indexes :reported_vin_number,     :as => :reported_vin
    indexes :time_zone

    indexes tracker.imei_number,      :as => :tracker_id

    indexes tags(:name),              :as => :tag

    has :account_id, :user_id, :created_at, :updated_at

    set_property :delta => true
  end

end
