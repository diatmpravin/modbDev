class AddProfileIdToDevices < ActiveRecord::Migration
  def self.up
    add_column :devices, :device_profile_id, :integer
  end

  def self.down
    remove_column :devices, :device_profile_id
  end
end
