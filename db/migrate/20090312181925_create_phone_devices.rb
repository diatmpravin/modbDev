class CreatePhoneDevices < ActiveRecord::Migration
  def self.up
    create_table :phone_devices do |t|
      t.integer :phone_id
      t.integer :device_id
      t.timestamps
    end
  end

  def self.down
    drop_table :phone_devices
  end
end