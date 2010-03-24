class Event < ActiveRecord::Base
  belongs_to :point
  belongs_to :geofence
  belongs_to :landmark
  
  before_create :default_occurred_at
  
  # Scope only points within the given date range
  named_scope :in_range, lambda { |start_date, end_date, zone|
    {
      :conditions => [
        "events.occurred_at BETWEEN ? AND ?",
        zone.parse(start_date.to_s),
        zone.parse(end_date.to_s).end_of_day
      ]
    }
  }
  
  ENTER_BOUNDARY = 1
  EXIT_BOUNDARY = 2
  SPEED = 3
  RPM = 4
  RAPID_ACCEL = 5
  RAPID_DECEL = 6
  IDLE = 7
  AFTER_HOURS = 8
  VIN_MISMATCH = 10
  RESET = 11
  NOT_REPORTING = 12  
  ENTER_LANDMARK = 13
  EXIT_LANDMARK = 14

  TEXT = {
    ENTER_BOUNDARY => 'Enter Boundary',
    EXIT_BOUNDARY => 'Exit Boundary',
    SPEED => 'Speed Exceed',
    RPM => 'RPM Exceed',
    RAPID_ACCEL => 'Accel Exceed',
    RAPID_DECEL => 'Decel Exceed',
    IDLE => 'Idle',
    AFTER_HOURS => 'After Hours',
    VIN_MISMATCH => 'VIN Mismatch',
    RESET => 'Device Power Reset',
    NOT_REPORTING => 'Device Not Reporting',
    ENTER_LANDMARK => 'Enter Landmark',
    EXIT_LANDMARK => 'Exit Landmark'
  }
  
  attr_accessible :event_type, :geofence_name, :speed_threshold, :point, :landmark, :geofence,
    :occurred_at
  
  def type_text
    TEXT[event_type] || 'Unknown'
  end
  
  def default_occurred_at
    self.occurred_at ||= (point ? point.occurred_at : Time.now.utc)
  end
end
