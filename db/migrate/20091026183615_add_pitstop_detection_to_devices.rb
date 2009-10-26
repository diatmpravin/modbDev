class AddPitstopDetectionToDevices < ActiveRecord::Migration
  def self.up
    add_column :devices, :detect_pitstops, :boolean, :default => false
    add_column :devices, :pitstop_threshold, :integer, :default => 10
  end

  def self.down
    remove_column :devices, :detect_pitstops
    remove_column :devices, :pitstop_threshold
  end
end
