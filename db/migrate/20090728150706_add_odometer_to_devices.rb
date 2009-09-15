class AddOdometerToDevices < ActiveRecord::Migration
  def self.up
    add_column :devices, :odometer, :integer
  end

  def self.down
    remove_column :devices, :odometer
  end
end