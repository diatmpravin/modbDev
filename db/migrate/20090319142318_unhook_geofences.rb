class UnhookGeofences < ActiveRecord::Migration
  def self.up
    add_column :geofences, :account_id, :integer
    remove_column :geofences, :device_id
  end

  def self.down
    remove_column :geofences, :account_id
    add_column :geofences, :device_id, :integer
  end
end
