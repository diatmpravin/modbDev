class AddDeltaToTrackers < ActiveRecord::Migration
  def self.up
    add_column :trackers, :delta, :boolean, :default => true, :null => false
  end

  def self.down
    remove_column :trackers, :delta
  end
end
