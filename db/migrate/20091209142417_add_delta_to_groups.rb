class AddDeltaToGroups < ActiveRecord::Migration
  def self.up
    add_column :groups, :delta, :boolean, :default => true
  end

  def self.down
    remove_column :groups, :delta
  end
end
