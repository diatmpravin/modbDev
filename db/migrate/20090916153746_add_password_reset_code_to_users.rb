class AddPasswordResetCodeToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :password_reset_code, :string, :limit => 48
  end

  def self.down
    remove_column :users, :password_reset_code
  end
end
