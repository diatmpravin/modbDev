class CreateTrackers < ActiveRecord::Migration
  def self.up
    create_table :trackers do |t|
      t.string :imei_number, :limit => 32
      t.string :sim_number, :limit => 32
      t.integer :status, :default => 0
      t.timestamps
    end
  end

  def self.down
    drop_table :trackers
  end
end