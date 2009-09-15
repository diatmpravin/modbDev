class AddFieldsToDevice < ActiveRecord::Migration
  def self.up
    add_column :devices, :fw_version, :string, :limit => 32
    add_column :devices, :obd_fw_version, :string, :limit => 32
    add_column :devices, :profile, :string, :limit => 16
    add_column :devices, :vin_number, :string, :limit => 17
    add_column :devices, :reported_vin_number, :string, :limit => 17
  end

  def self.down
    remove_column :devices, :fw_version
    remove_column :devices, :obd_fw_version
    remove_column :devices, :profile
    remove_column :devices, :vin_number
    remove_column :devices, :reported_vin_number
  end
end