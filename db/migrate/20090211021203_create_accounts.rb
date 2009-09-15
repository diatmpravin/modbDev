class CreateAccounts < ActiveRecord::Migration
  def self.up
    create_table :accounts do |t|
      t.string :login, :limit => 30
      t.string :email, :limit => 50
      t.string :crypted_password, :limit => 40
      t.string :salt, :limit => 40
      t.string :remember_token
      t.datetime :remember_token_expires_at
      t.timestamps
    end
  end

  def self.down
    drop_table :accounts
  end
end
