class CreateDevices < ActiveRecord::Migration
  def self.up
    create_table :devices do |t|
      t.integer :account_id
      t.string :name, :limit => 30
      t.string :sim_number, :limit => 32
      t.timestamps
    end
  end

  def self.down
    drop_table :devices
  end
end
