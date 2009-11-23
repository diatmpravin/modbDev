class AddDeltaToDevices < ActiveRecord::Migration
  def self.up
    add_column :devices, :delta, :boolean, :default => true, :null => false
    add_index :devices, :delta
  end

  def self.down
    remove_column :devices, :delta
  end
end
