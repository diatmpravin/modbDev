class AddAlertOnResetToDeviceProfiles < ActiveRecord::Migration
  def self.up
    add_column :device_profiles, :alert_on_reset, :boolean
  end

  def self.down
    remove_column :device_profiles, :alert_on_reset
  end
end
