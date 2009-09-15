class PhonesTripsCleanup < ActiveRecord::Migration
  def self.up
    remove_column :phones, :phone_number
    remove_column :phones, :phone_carrier_id
    remove_column :trips, :name
  end

  def self.down
    add_column :phones, :phone_number, :string, :limit => 10
    add_column :phones, :phone_carrier_id, :integer
    add_column :trips, :name, :string, :limit => 30
  end
end