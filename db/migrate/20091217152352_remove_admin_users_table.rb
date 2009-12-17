class RemoveAdminUsersTable < ActiveRecord::Migration
  def self.up
    drop_table :admin_users
  end

  def self.down
    create_table :admin_users do |t|
      t.string :login, :limit => 50
      t.string :crypted_password, :limit => 40
      t.string :salt, :limit => 40
      t.timestamps
    end
  end
end
