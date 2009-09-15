class AddDeviceIdToPoints < ActiveRecord::Migration
  def self.up
    add_column :points, :device_id, :integer
  end

  def self.down
    remove_column :points, :device_id
  end
end