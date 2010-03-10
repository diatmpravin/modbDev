class AddMpgToDailyData < ActiveRecord::Migration
  def self.up
    add_column :device_data_per_day, :mpg, :float
  end

  def self.down
    remove_column :device_data_per_day, :mpg
  end
end
