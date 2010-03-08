class DeviceDataPerDay < ActiveRecord::Base
  set_table_name :device_data_per_day
  belongs_to :device

  attr_accessible :date, :duration, :miles, :speed_events, :geofence_events,
      :idle_events, :aggressive_events, :after_hours_events, :first_start_time,
      :last_end_time

  # Get the device data for a given day
  named_scope :for, lambda {|date|
    {:conditions => {:date => date}}
  }
end
