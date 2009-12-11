class AddDefaultsToDeviceProfile < ActiveRecord::Migration
  def self.up
    change_column :device_profiles, :alert_on_speed, :boolean, :default => false
    change_column :device_profiles, :speed_threshold, :integer, :default => 70
    change_column :device_profiles, :alert_on_aggressive, :boolean, :default => false
    change_column :device_profiles, :rpm_threshold, :integer, :default => 5000
    change_column :device_profiles, :alert_on_idle, :boolean, :default => false
    change_column :device_profiles, :idle_threshold, :integer, :default => 5
    change_column :device_profiles, :alert_on_after_hours, :boolean, :default => false
    change_column :device_profiles, :after_hours_start, :integer, :default => 79200
    change_column :device_profiles, :after_hours_end, :integer, :default => 21600
    change_column :device_profiles, :detect_pitstops, :boolean, :default => false
    change_column :device_profiles, :pitstop_threshold, :integer, :default => 10
    change_column :device_profiles, :time_zone, :string, :limit => 64, :default => "Eastern Time (US & Canada)"
  end

  def self.down
    change_column :device_profiles, :alert_on_speed, :boolean
    change_column :device_profiles, :speed_threshold, :integer
    change_column :device_profiles, :alert_on_aggressive, :boolean
    change_column :device_profiles, :rpm_threshold, :integer
    change_column :device_profiles, :alert_on_idle, :boolean
    change_column :device_profiles, :idle_threshold, :integer
    change_column :device_profiles, :alert_on_after_hours, :boolean
    change_column :device_profiles, :after_hours_start, :integer
    change_column :device_profiles, :after_hours_end, :integer
    change_column :device_profiles, :detect_pitstops, :boolean
    change_column :device_profiles, :pitstop_threshold, :integer
    change_column :device_profiles, :time_zone, :string, :limit => 64  
  end
end
