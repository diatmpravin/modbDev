class AddMsisdnToTrackers < ActiveRecord::Migration
  def self.up
    add_column :trackers, :msisdn_number, :string, :limit => 32
  end

  def self.down
    remove_column :trackers, :msisdn_number
  end
end