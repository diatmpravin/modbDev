class CreateGeofences < ActiveRecord::Migration
  def self.up
    create_table :geofences do |t|
      t.integer :device_id
      t.integer :geofence_type
      t.text :coordinates
      t.integer :radius
      t.timestamps
    end
  end

  def self.down
    drop_table :geofences
  end
end
