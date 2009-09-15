class FixDeviceAlerts < ActiveRecord::Migration
  def self.up
    add_column :devices, :alert_on_aggressive, :boolean, :default => false
    remove_column :devices, :alert_on_acceleration
    remove_column :devices, :alert_on_deceleration
    remove_column :devices, :alert_on_rpm
    
    add_column :devices, :alert_on_idle, :boolean, :default => false
    add_column :devices, :alert_on_after_hours, :boolean, :default => false
    add_column :devices, :idle_threshold, :integer
    add_column :devices, :after_hours_start, :integer
    add_column :devices, :after_hours_end, :integer
  end

  def self.down
    remove_column :devices, :alert_on_aggressive
    add_column :devices, :alert_on_acceleration, :boolean, :default => false
    add_column :devices, :alert_on_deceleration, :boolean, :default => false
    add_column :devices, :alert_on_rpm, :boolean, :default => false
    
    remove_column :devices, :alert_on_idle
    remove_column :devices, :alert_on_after_hours
    remove_column :devices, :idle_threshold
    remove_column :devices, :after_hours_start
    remove_column :devices, :after_hours_end
  end
end