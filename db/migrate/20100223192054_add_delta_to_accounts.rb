class AddDeltaToAccounts < ActiveRecord::Migration
  def self.up
    add_column :accounts, :delta, :boolean, :default => true, :null => false
  end

  def self.down
    remove_column :accounts, :delta
  end
end
