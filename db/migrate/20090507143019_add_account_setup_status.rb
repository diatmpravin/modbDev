class AddAccountSetupStatus < ActiveRecord::Migration
  def self.up
    add_column :accounts, :setup_status, :integer, :default => 1
    Account.find(:all).each do |a|
      a.update_attribute(:setup_status, 0)
    end
  end

  def self.down
    remove_column :accounts, :setup_status
  end
end