class Report
  class VehicleSummaryReport < Generator
    # COLUMNS = {
    #   :name        => 'Vehicle',
    #   :miles       => 'Miles Driven',
    #   :duration    => 'Operating Time',
    #   :idle_time   => 'Idle Time',
    #   :speed       => 'Speed',
    #   :geofence    => 'Geofence',
    #   :idle_alert  => 'Idle',
    #   :aggressive  => 'Aggressive',
    #   :after_hours => 'After Hours'
    # }

    def run
      return nil unless valid?

      report = Ruport::Data::Table(
        :name,
        :miles,
        :duration,
        :idle_time,
        :speed,
        :geofence,
        :idle_time,
        :aggressive,
        :after_hours
      )

      devices.each do |device|
        trips = device.trips.in_range(self.start, self.end, self.account.zone)

        # Do event grouping in database
        events = device.events.in_range(self.start, self.end, self.account.zone).all(
          :select => 'event_type, COUNT(*) AS count_all',
          :group => :event_type
        ).map {|e| [e.event_type, e.count_all.to_i]}
        
        # Hashify
        events = Hash[*events.inject([]) {|arr, elem| arr.concat(elem)}]
        
        report << {
          :name => device.name,
          :miles => trips.map {|t| t.miles}.sum,
          :duration => duration_format(trips.map {|t| t.duration}.sum),
          :idle_time => duration_format(trips.map {|t| t.idle_time}.sum),
          :speed => events[Event::SPEED] || 0,
          :geofence => [
            events[Event::ENTER_BOUNDARY] || 0,
            events[Event::EXIT_BOUNDARY] || 0
          ].sum,
          :idle_time => events[Event::IDLE] || 0,
          :aggressive => [
            events[Event::RPM] || 0,
            events[Event::RAPID_ACCEL] || 0,
            events[Event::RAPID_DECEL] || 0
          ].sum,
          :after_hours => events[Event::AFTER_HOURS] || 0
        }
      end
      
      report
    end

    def valid?
      if(devices.blank?)
        self.errors << 'You must choose one or more vehicles to run this report' 
      end

      self.errors.empty?
    end

    def title
      "Vehicle Summary Report - #{self.start} through #{self.end}"
    end
  end
end
