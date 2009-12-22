class LockVinOnDevices < ActiveRecord::Migration
  def self.up
    add_column :devices, :lock_vin, :boolean, :default => false
  end

  def self.down
    remove_column :devices, :lock_vin
  end
end
