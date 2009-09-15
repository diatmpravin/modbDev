class AddActivationToAccounts < ActiveRecord::Migration
  def self.up
    add_column :accounts, :activation_code, :string, :limit => 40
    add_column :accounts, :activated_at, :datetime
  end

  def self.down
    remove_column :accounts, :activation_code
    remove_column :accounts, :activated_at
  end
end