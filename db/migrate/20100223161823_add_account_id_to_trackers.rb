class AddAccountIdToTrackers < ActiveRecord::Migration
  def self.up
    add_column :trackers, :account_id, :integer
  end

  def self.down
    remove_column :trackers, :account_id
  end
end
