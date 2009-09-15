class AddMaxSpeedToDevices < ActiveRecord::Migration
  def self.up
    add_column :devices, :speed_threshold, :integer, :default => 75
    add_column :devices, :alert_on_speed, :boolean, :default => false
    add_column :devices, :rpm_threshold, :integer, :default => 5000
    add_column :devices, :alert_on_rpm, :boolean, :default => false
  end

  def self.down
    remove_column :devices, :speed_threshold
    remove_column :devices, :alert_on_speed
    remove_column :devices, :rpm_threshold
    remove_column :devices, :alert_on_rpm
  end
end