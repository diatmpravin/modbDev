class AddDeviceIdToTrips < ActiveRecord::Migration
  def self.up
    add_column :trips, :device_id, :integer
  end

  def self.down
    remove_column :trips, :device_id
  end
end
