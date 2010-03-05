# Used by the report card page, this is very close to a copy of the VehicleSummaryReport
# but with a few important changes.
#
# TODO Find a way to clean up this duplication
class GroupVehiclesReport < Report

  attr_accessor :group

  def initialize(user, options = {})
    @group = options.delete(:group)
    options[:devices] = @group.devices

    super(user, options)
  end

  def title
    "Group Vehicles Report - #{self.start} through #{self.end}"
  end

  def to_csv
    self.data.rename_columns(
      :name => "Name",
      :duration => "Operating Time (s)",
      :miles => "Miles",
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
      :duration,
      :miles,
      :event_speed,
      :event_geofence,
      :event_idle,
      :event_aggressive,
      :event_after_hours,
      :first_start_time
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

      first_start_time = trips.any? ? trips.first.start : nil

      report << {
        :name => device.name,
        :miles => trips.map {|t| t.miles}.sum,
        :duration => trips.map {|t| t.duration}.sum,
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
        :event_after_hours => events[Event::AFTER_HOURS] || 0,
        :first_start_time => first_start_time
      }
    end

    self.data = report
  end

end
