class TripDetailReport < Report

  def title
    "Trip Detail Report - #{self.start} through #{self.end}"
  end

  def validate
    if(devices.blank? || devices.length != 1)
      self.errors << 'You must choose one vehicle to run this report'
    end
  end

  def device
    self.devices.first
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

    trips.each do |trip|
      # Count the number of each events for the trip
      events = [].tap do |events|
        trip.events.each do |e|
          events[e.event_type] ||= 0
          events[e.event_type] += 1
        end
      end

      self.data << {
        :start => trip.start.in_time_zone(self.user.zone),
        :finish => trip.finish.in_time_zone(self.user.zone),
        :miles => trip.miles,
        :mpg => trip.average_mpg,
        :duration => trip.duration,
        :idle_time => trip.idle_time,
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
  end

end
