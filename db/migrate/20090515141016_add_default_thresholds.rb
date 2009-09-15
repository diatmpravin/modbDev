class AddDefaultThresholds < ActiveRecord::Migration
  def self.up
    change_column :devices, :speed_threshold, :integer, :default => 70
    change_column :devices, :idle_threshold, :integer, :default => 5
    change_column :devices, :after_hours_start, :integer, :default => 79200 # 10pm
    change_column :devices, :after_hours_end, :integer, :default => 21600 # 6am
  end

  def self.down
    # unnecessary
  end
end