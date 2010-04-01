class DeviceDataPerDay < ActiveRecord::Base
  set_table_name :device_data_per_day
  belongs_to :device

  attr_accessible :date, :mpg, :duration, :miles, :speed_events, :geofence_events,
      :idle_events, :aggressive_events, :after_hours_events, :first_start_time,
      :last_end_time, :first_start, :last_stop

  # Get the device data for a given day
  named_scope :for, lambda {|date|
    {:conditions => {:date => date}}
  }

  named_scope :for_range, lambda {|from, to|
    {:conditions => {:date => (from..to).to_a}}
  }

  default_value_for :duration, 0
  default_value_for :miles, 0

  def zone
    ActiveSupport::TimeZone[self[:time_zone]]
  end

  # Merge another instance of this class into this instance
  def merge!(other)
    return unless other

    self.mpg = (self.mpg + other.mpg) / 2.0
    self.duration += other.duration
    self.miles += other.miles
    self.speed_events += other.speed_events
    self.geofence_events += other.geofence_events
    self.idle_events += other.idle_events
    self.aggressive_events += other.aggressive_events
    self.after_hours_events += other.after_hours_events

    if self.first_start_time.nil? || (other.first_start_time &&
      other.first_start_time.seconds_since_midnight < self.first_start_time.seconds_since_midnight)
      self.first_start_time = other.first_start_time
    end

    if self.last_end_time.nil? || (other.last_end_time &&
      other.last_end_time.seconds_since_midnight > self.last_end_time.seconds_since_midnight)
      self.last_end_time = other.last_end_time
    end
  end
end
