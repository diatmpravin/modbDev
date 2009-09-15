class AddColorToDevices < ActiveRecord::Migration
  def self.up
    add_column :devices, :color_id, :integer, :default => 0
  end

  def self.down
    remove_column :devices, :color_id
  end
end