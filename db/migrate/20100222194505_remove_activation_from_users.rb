class RemoveActivationFromUsers < ActiveRecord::Migration
  def self.up
    remove_column :users, :activation_code
    remove_column :users, :activated_at
  end

  def self.down
    add_column :users, :activation_code, :string, :limit => 40
    add_column :users, :activated_at, :datetime
  end
end
