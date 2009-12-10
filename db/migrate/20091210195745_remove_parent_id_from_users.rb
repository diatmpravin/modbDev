class RemoveParentIdFromUsers < ActiveRecord::Migration
  def self.up
    remove_column :users, :parent_id
  end

  def self.down
    add_column :users, :parent_id, :integer
  end
end

