class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.integer :account_id
      t.integer :parent_user_id
      t.string :login, :limit => 30
      t.string :crypted_password, :limit => 40
      t.string :salt, :limit => 40
      t.string :name, :limit => 30
      t.string :email, :limit => 50
      t.integer :roles
      t.timestamps
    end
  end

  def self.down
    drop_table :users
  end
end