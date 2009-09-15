class MakeUserRoleDefault < ActiveRecord::Migration
  def self.up
    change_column :users, :roles, :integer, :default => 0
  end

  def self.down
    change_column :users, :roles, :integer
  end
end