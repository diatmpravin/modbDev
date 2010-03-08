class AddDeviceDataPerDay < ActiveRecord::Migration
  def self.up
    create_table :device_data_per_day, :force => true do |t|
      t.integer :device_id
      t.date    :date
      t.integer :duration
      t.integer :miles
      t.integer :speed_events
      t.integer :geofence_events
      t.integer :idle_events
      t.integer :aggressive_events
      t.integer :after_hours_events
      t.time    :first_start_time
      t.time    :last_end_time
    end
  end

  def self.down
    drop_table :device_data_per_day
  end
end
