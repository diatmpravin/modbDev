class CreateAdminUsers < ActiveRecord::Migration
  def self.up
    create_table :admin_users do |t|
      t.string :login, :limit => 50
      t.string :crypted_password, :limit => 40
      t.string :salt, :limit => 40
      t.timestamps
    end
  end

  def self.down
    drop_table :admin_users
  end
end