class AddLeftAndRightToAccount < ActiveRecord::Migration
  def self.up
    add_column :accounts, :lft, :integer
    add_column :accounts, :rgt, :integer
  end

  def self.down
    remove_column :accounts, :lft
    remove_column :accounts, :rgt
  end
end
