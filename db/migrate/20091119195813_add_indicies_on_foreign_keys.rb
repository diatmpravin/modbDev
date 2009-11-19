class AddIndiciesOnForeignKeys < ActiveRecord::Migration
  def self.up
    {
      :accounts => [:parent_id],
      :alert_recipients => [:account_id],
      :device_geofences => [:device_id, :geofence_id],
      :devices => [:account_id, :user_id, :tracker_id],
      :events => [:point_id],
      :geofences => [:account_id],
      :landmarks => [:account_id],
      :legs => [:trip_id],
      :phones => [:account_id],
      :points => [:leg_id, :device_id],
      :tags => [:account_id],
      :trackers => [:imei_number],
      :trips => [:device_id],
      :users => [:parent_id, :account_id]
    }.each do |table, columns|
      columns.each do |col|
        add_index table, col
      end
    end
  end

  def self.down
  end
end
