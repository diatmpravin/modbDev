class RemoveDeviceGeofenceTable < ActiveRecord::Migration
  def self.up
    drop_table :device_geofences
  end

  def self.down
    create_table :device_geofences do |t|
      t.integer :device_id
      t.integer :geofence_id
      t.timestamps
    end
  end
end
