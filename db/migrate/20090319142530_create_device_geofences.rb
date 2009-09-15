class CreateDeviceGeofences < ActiveRecord::Migration
  def self.up
    create_table :device_geofences do |t|
      t.integer :device_id
      t.integer :geofence_id
      t.timestamps
    end
  end

  def self.down
    drop_table :device_geofences
  end
end
