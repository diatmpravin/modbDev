class RenameParentIds < ActiveRecord::Migration
  def self.up
    rename_column :accounts, :parent_account_id, :parent_id
    rename_column :users, :parent_user_id, :parent_id
  end

  def self.down
    rename_column :accounts, :parent_id, :parent_account_id
    rename_column :users, :parent_id, :parent_user_id
  end
end
