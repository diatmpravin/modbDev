class AddTimeZoneToDailyData < ActiveRecord::Migration
  def self.up
    add_column :device_data_per_day, :time_zone, :string, :default => "Eastern Time (US & Canada)"
  end

  def self.down
    remove_column :device_data_per_day, :time_zone
  end
end
