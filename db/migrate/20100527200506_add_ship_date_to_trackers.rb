class AddShipDateToTrackers < ActiveRecord::Migration
  def self.up
    add_column :trackers, :shipped_on, :date
  end

  def self.down
    remove_column :trackers, :shipped_on, :date
  end
end
