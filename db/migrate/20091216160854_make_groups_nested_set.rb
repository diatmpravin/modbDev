class MakeGroupsNestedSet < ActiveRecord::Migration
  def self.up
    add_column :groups, :parent_id, :integer
    add_column :groups, :lft, :integer
    add_column :groups, :rgt, :integer
  end

  def self.down
    remove_column :groups, :parent_id
    remove_column :groups, :lft
    remove_column :groups, :rgt
  end
end
