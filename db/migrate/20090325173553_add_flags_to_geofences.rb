class AddFlagsToGeofences < ActiveRecord::Migration
  def self.up
    add_column :geofences, :alert_on_exit, :boolean, :default => false
    add_column :geofences, :alert_on_entry, :boolean, :default => false
  end

  def self.down
    remove_column :geofences, :alert_on_exit
    remove_column :geofences, :alert_on_entry
  end
end