class RemovePhoneDevicesTable < ActiveRecord::Migration
  def self.up
    drop_table :phone_devices
  end

  def self.down
    create_table :phone_devices do |t|
      t.integer :phone_id
      t.integer :device_id
      t.timestamps
    end
  end
end
