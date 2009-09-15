class AddTzToAccounts < ActiveRecord::Migration
  def self.up
    add_column :accounts, :time_zone, :string, :limit => 64, :default => "Eastern Time (US & Canada)"
  end

  def self.down
    remove_column :accounts, :time_zone
  end
end
