class TripDetailReport < Report

  def title
    "Trip Detail Report for #{self.device.name} - #{self.start} through #{self.end}"
  end

  def validate
    if(devices.blank? || devices.length != 1)
      self.errors << 'You must choose one vehicle to run this report'
    end
  end

  def device
    self.devices.first
  end

  def to_csv
    self.data.rename_columns(
      :start => "Start Date",
      :finish => "End Date",
      :miles => "Miles",
      :mpg => "MPG",
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
      :start,
      :finish,
      :miles,
      :mpg,
      :idle_time,
      :event_speed,
      :event_geofence,
      :event_idle,
      :event_aggressive,
      :event_after_hours
    )

    trips = self.device.trips.in_range(
      self.start, self.end, self.user.zone
    ).all(:order => 'start ASC')
    
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
      
      self.data << {
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
