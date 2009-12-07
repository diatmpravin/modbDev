class AddNameToDeviceProfile < ActiveRecord::Migration
  def self.up
    add_column :device_profiles, :name, :string, :limit => 30
  end

  def self.down
    remove_column :device_profiles, :name
  end
end
