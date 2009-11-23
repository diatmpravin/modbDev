class Device < ActiveRecord::Base

  ##
  # Sphinx Index Definitions
  ##
  define_index do
    indexes :name, :sortable => true
    indexes :obd_fw_version
    indexes :vin_number
    indexes :reported_vin_number
    indexes :time_zone

    indexes tracker.imei_number, :as => :tracker_id

    has :account_id, :user_id, :created_at, :updated_at

    set_property :delta => true
  end

end
