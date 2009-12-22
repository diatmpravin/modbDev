class CreateGeofenceDeviceGroup < ActiveRecord::Migration
  def self.up
    create_table :geofence_device_groups, :id => false do |t|
      t.integer :geofence_id
      t.integer :group_id
    end
  end

  def self.down
    drop_table :geofence_device_groups
  end
end
