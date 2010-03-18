class CreateLandmarkDeviceGroup < ActiveRecord::Migration
  def self.up
    create_table :landmark_device_groups, :id => false do |t|
      t.integer :landmark_id
      t.integer :group_id
    end
  end

  def self.down
    drop_table :landmark_device_groups
  end
end
