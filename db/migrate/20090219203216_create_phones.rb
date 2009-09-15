class CreatePhones < ActiveRecord::Migration
  def self.up
    create_table :phones do |t|
      t.integer :account_id
      t.string :name, :limit => 30
      t.string :phone_number, :limit => 10
      t.integer :phone_carrier_id
      t.string :moshi_key, :limit => 32
      t.integer :request_id, :default => 0
      t.timestamps
    end
  end

  def self.down
    drop_table :phones
  end
end