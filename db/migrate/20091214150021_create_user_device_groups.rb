class CreateUserDeviceGroups < ActiveRecord::Migration
  def self.up
    create_table :user_device_groups, :id => false do |t|
      t.integer :user_id
      t.integer :group_id
    end
  end
  
  def self.down
    drop_table :user_device_groups
  end
end
