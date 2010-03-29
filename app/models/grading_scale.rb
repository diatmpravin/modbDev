class GradingScale < ActiveRecord::Base
  belongs_to :device_group

  attr_accessible :mpg_fail, :mpg_pass, :speed_events_fail, :speed_events_pass, :geofence_events_fail, 
  :geofence_events_pass, :idle_events_fail, :idle_events_pass, :aggressive_events_fail, :aggressive_events_pass, 
  :after_hours_events_fail, :after_hours_events_pass, :first_start_fail, :first_start_pass, :last_stop_fail, :last_stop_pass

 
end
