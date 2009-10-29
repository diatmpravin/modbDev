class VehicleSummaryReport < Report

  def validate
    if(devices.blank?)
      self.errors << 'You must choose one or more vehicles to run this report' 
    end
  end

  def title
    "Vehicle Summary Report - #{self.start} through #{self.end}"
  end

  def to_csv
    self.data.rename_columns(
      :name => "Name",
      :miles => "Miles",
      :mpg => "MPG",
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
    report = Ruport::Data::Table(
      :name,
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

    devices.each do |device|
      trips = device.trips.in_range(self.start, self.end, self.user.zone)

      # Do event grouping in database
      events = device.events.in_range(self.start, self.end, self.user.zone).all(
        :select => 'event_type, COUNT(*) AS count_all',
        :group => :event_type
      ).map {|e| [e.event_type, e.count_all.to_i]}
      
      # Hashify
      events = Hash[*events.inject([]) {|arr, elem| arr.concat(elem)}]

      # Make sure not to divide mpg by 0
      if(trips.size == 0)
        mpg = 0
      else
        mpg = trips.map {|t| t.average_mpg}.sum / trips.size.to_f
      end
      
      report << {
        :name => device.name,
        :miles => trips.map {|t| t.miles}.sum,
        :mpg => mpg,
        :duration => trips.map {|t| t.duration}.sum,
        :idle_time => trips.map {|t| t.idle_time}.sum,
        :event_speed => events[Event::SPEED] || 0,
        :event_geofence => [
          events[Event::ENTER_BOUNDARY] || 0,
          events[Event::EXIT_BOUNDARY] || 0
        ].sum,
        :event_idle => events[Event::IDLE] || 0,
        :event_aggressive => [
          events[Event::RPM] || 0,
          events[Event::RAPID_ACCEL] || 0,
          events[Event::RAPID_DECEL] || 0
        ].sum,
        :event_after_hours => events[Event::AFTER_HOURS] || 0
      }
    end

    self.data = report
  end

end
