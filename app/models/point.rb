class Point < ActiveRecord::Base
  include DeviceReport::Event
  
  belongs_to :leg
  belongs_to :device
  
  has_many :events
  
  # Scope only points that are part of a trip
  named_scope :in_trip, :conditions => "leg_id IS NOT NULL" do
    def trips
      all(:group => :leg_id, :include => {:leg => :trip}).map {|p| p.leg.trip}
    end
  end
  
  # Scope only points before the given datetime
  named_scope :before, lambda { |datetime|
    {
      :conditions => ["occurred_at < ?", datetime.utc]
    }
  }
  
  # Scope only points after the given datetime
  named_scope :after, lambda { |datetime|
    {
      :conditions => ["occurred_at > ?", datetime.utc]
    }
  }
  
  # Scope only points within the given date range
  named_scope :in_range, lambda { |start_date, end_date, zone|
    {
      :conditions => [
        "occurred_at BETWEEN ? AND ?",
        zone.parse(start_date.to_s),
        zone.parse(end_date.to_s).end_of_day
      ], :order => "occurred_at ASC"
    }
  }
  
  # Scope only points capable of starting or ending a trip
  named_scope :trip_markers, :conditions => {:event =>
    [
      PERIODIC_IGNITION_OFF,
      PERIODIC_IGNITION_ON,
      SPEED,
      IGNITION_ON,
      IGNITION_OFF,
      RESET
    ]
  }
  
  validates_presence_of :device
  validates_presence_of :occurred_at
  
  attr_accessible :event, :occurred_at, :latitude, :longitude, :altitude,
    :speed, :accelerating, :decelerating, :rpm, :heading, :satellites,
    :hdop, :miles, :leg, :device, :mpg
  
  after_save :update_precalc_fields
  
  # Fill in any appropriate attributes in the given hash
  def parse(report)
    self.event = report[:event]
    begin
      self.occurred_at = Time.parse("#{report[:date]} #{report[:time]} UTC")
    rescue ArgumentError
      self.occurred_at = Time.now
    end
    self.latitude = report[:latitude].to_f
    self.longitude = report[:longitude].to_f
    self.altitude = report[:altitude].to_i
    self.speed = report[:speed].to_i
    self.accelerating = report[:accelerating] == '1'
    self.decelerating = report[:decelerating] == '1'
    self.rpm = report[:rpm].to_i
    self.heading = report[:heading].to_i
    self.satellites = report[:satellites].to_i
    self.hdop = report[:hdop].to_f
    self.miles = report[:miles].to_i
    
    self.mpg = report[:mpg].to_f if report[:mpg]
    self.battery = report[:battery].to_f if report[:battery]
    self.signal = report[:signal].to_i if report[:signal]
    self.locked = !(report[:gps] == '0')
  end
  
  def running?
    [
      PERIODIC_IGNITION_ON,
      SPEED,
      IGNITION_ON
    ].include?(self.event)
  end
  
  def trip_marker?
    [
      PERIODIC_IGNITION_OFF,
      PERIODIC_IGNITION_ON,
      SPEED,
      IGNITION_ON,
      IGNITION_OFF,
      RESET
    ].include?(self.event)
  end
  
  # Used when converted to JSON
  def time_of_day
    occurred_at.to_time.in_time_zone(device.zone).to_s(:local)
  end
  
  # Update any precalc fields on the prior point, and then on this point if
  # it isn't the last one, and then on the parent leg if it exists.
  def update_precalc_fields
    pre = device.points.before(occurred_at).first(
      :select => 'id, occurred_at', :order => 'occurred_at DESC'
    )
    post = device.points.after(occurred_at).first(
      :select => 'id, occurred_at', :order => 'occurred_at ASC'
    )
    
    # Direct updates to avoid a huge cascade of after_save callbacks
    if pre
      Point.update_all({:duration => occurred_at - pre.occurred_at}, {:id => pre.id})
    end
    
    if post
      Point.update_all({:duration => post.occurred_at - occurred_at}, {:id => id})
    end

    if device.name.match("Load 9")
      return
    end

    leg.update_precalc_fields if leg
  end
end
