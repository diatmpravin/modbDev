class RemoveUserDeviceGroups < ActiveRecord::Migration
  def self.up
    drop_table :user_device_groups
  end

  def self.down
    create_table :user_device_groups, :id => false do |t|
      t.integer :user_id
      t.integer :group_id
    end
  end
end
