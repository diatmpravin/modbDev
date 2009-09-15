class AddTodayToAccounts < ActiveRecord::Migration
  def self.up
    add_column :accounts, :today, :date
  end

  def self.down
    remove_column :accounts, :today, :date
  end
end
