class AfterHoursDetailReport < Report

  def title
    "After Hours Detail Report - #{self.start} through #{self.end}"
  end

  def validate
    if devices.blank?
      self.errors << 'You must choose one or more vehicles to run this report' 
    end
  end

  def to_csv
    self.data.rename_columns(
      :vehicle => "Vehicle",
      :start => "Start Date",
      :finish => "End Date",
      :miles => "Miles",
      :mpg => "Average Fuel Economy",
      :duration => "Operating Time (s)",
      :idle_time => "Idle Time (s)",
      :event_speed => "Speed Events",
      :event_geofence => "Geofence Events",
      :event_idle => "Idle Events",
      :event_aggressive => "Aggressive Events",
      :event_after_hours => "After Hours Events"
    )
    super
  end

  def run
    self.data = Ruport::Data::Table(
      :vehicle,
      :start,
      :finish,
      :miles,
      :mpg,
      :duration,
      :idle_time,
      :event_speed,
      :event_geofence,
      :event_idle,
      :event_aggressive,
      :event_after_hours
    )

    # TODO right now, this is pulling in all trips, and all events for those trips, even though
    # we only end up showing trips that have at least one after hours event.  Perhaps this could
    # be changed so that we don't pull in all of the trips and discarding those that aren't after
    # hours    

    trips = Trip.in_range(
      self.start, self.end, self.user.zone
    ).all(
      :order => 'start ASC',
      :conditions => {:device_id => self.devices.map(&:id)},
      :include => :device
    )
    
    # Get event counts from db grouped by trip and event type, then turn the
    # results into a hash.
    events = Hash.new {|hash, key| hash[key] = Hash.new(0)}
    Event.multi_count(
      :group => ['legs.trip_id', 'event_type'],
      :joins => {:point => :leg},
      :conditions => {'legs.trip_id' => trips.map(&:id)}
    ).each do |r|
      events[r[0][0].to_i][r[0][1].to_i] = r[1]
    end
    
    trips.each do |trip|
      trip_events = events[trip.id]

      # we're discarding any trip that doesn't have an after hours event
      if trip_events[Event::AFTER_HOURS] > 0       
        self.data << {
          :vehicle => trip.device.name,
          :start => trip.start.in_time_zone(self.user.zone),
          :finish => trip.finish.in_time_zone(self.user.zone),
          :miles => trip.miles,
          :mpg => trip.average_mpg,
          :duration => trip.duration,
          :idle_time => trip.idle_time,
          :event_speed => trip_events[Event::SPEED],
          :event_geofence => [
            trip_events[Event::ENTER_BOUNDARY],
            trip_events[Event::EXIT_BOUNDARY]
          ].sum,
          :event_idle => trip_events[Event::IDLE],
          :event_aggressive => [
            trip_events[Event::RPM],
            trip_events[Event::RAPID_ACCEL],
            trip_events[Event::RAPID_DECEL]
          ].sum,
          :event_after_hours => trip_events[Event::AFTER_HOURS]
        }
      end
    end
  end

end
