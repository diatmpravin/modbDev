class AddNameToGeofences < ActiveRecord::Migration
  def self.up
    add_column :geofences, :name, :string, :limit => 30
  end

  def self.down
    remove_column :geofences, :name
  end
end