class AccountsHaveChildren < ActiveRecord::Migration
  def self.up
    add_column :accounts, :parent_account_id, :integer
    add_column :accounts, :reseller, :boolean, :default => false
    add_column :accounts, :can_assign_reseller, :boolean, :default => false
  end

  def self.down
    remove_column :accounts, :parent_account_id
    remove_column :accounts, :reseller
    remove_column :accounts, :can_assign_reseller
  end
end
