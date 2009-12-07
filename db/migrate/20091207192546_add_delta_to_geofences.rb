class AddDeltaToGeofences < ActiveRecord::Migration
  def self.up
    add_column :geofences, :delta, :boolean, :default => true
  end

  def self.down
    remove_column :geofences, :delta
  end
end
