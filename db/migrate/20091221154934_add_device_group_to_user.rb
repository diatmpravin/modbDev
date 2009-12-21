class AddDeviceGroupToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :device_group_id, :integer
  end

  def self.down
    remove_column :users, :device_group_id
  end
end
