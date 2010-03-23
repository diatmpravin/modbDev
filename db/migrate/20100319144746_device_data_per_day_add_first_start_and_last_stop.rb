class DeviceDataPerDayAddFirstStartAndLastStop < ActiveRecord::Migration
  def self.up
    add_column :device_data_per_day, :first_start, :integer
    add_column :device_data_per_day, :last_stop, :integer
  end

  def self.down
    remove_column :device_data_per_day, :first_start, :integer
    remove_column :device_data_per_day, :last_stop, :integer
  end
end
