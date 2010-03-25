class AddGeofenceAndLandmarkIdToEvent < ActiveRecord::Migration
  def self.up
    add_column :events, :geofence_id, :integer
    add_column :events, :landmark_id, :integer
  end

  def self.down
    remove_column :events, :geofence_id
    remove_column :events, :landmark_id
  end
end
