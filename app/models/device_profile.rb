class DeviceProfile < ActiveRecord::Base
  belongs_to :account
  has_many :devices
  
  attr_accessible :account, :devices, :speed_threshold, :rpm_threshold,
    :alert_on_speed, :alert_on_aggressive, :alert_on_idle, :idle_threshold,
    :alert_on_after_hours, :after_hours_end, :after_hours_start, :detect_pitstops,
    :pitstop_threshold, :idle_threshold, :time_zone
  
end
