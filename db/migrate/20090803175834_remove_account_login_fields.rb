class RemoveAccountLoginFields < ActiveRecord::Migration
  def self.up
    remove_column :accounts, :login
    remove_column :accounts, :email
    remove_column :accounts, :crypted_password
    remove_column :accounts, :salt
    remove_column :accounts, :remember_token
    remove_column :accounts, :remember_token_expires_at
    remove_column :accounts, :activation_code
    remove_column :accounts, :activated_at
    remove_column :accounts, :time_zone
  end

  def self.down
    add_column :accounts, :login, :string, :limit => 30
    add_column :accounts, :email, :string, :limit => 50
    add_column :accounts, :crypted_password, :string, :limit => 40
    add_column :accounts, :salt, :string, :limit => 40
    add_column :accounts, :remember_token, :string
    add_column :accounts, :remember_token_expires_at, :datetime
    add_column :accounts, :activation_code, :string, :limit => 40
    add_column :accounts, :activated_at, :datetime
    add_column :accounts, :time_zone, :string, :limit => 64, :default => "Eastern Time (US & Canada)"
  end
end