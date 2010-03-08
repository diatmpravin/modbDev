# This report is basically identical to the VehicleSummaryReport, but instead
# it aggregates the summary across all vehicles in a group and this group's 
# sub-groups
class GroupSummaryReport < Report

  attr_accessor :group

  def initialize(user, options = {})
    @group = options.delete(:group)

    # We do our own device handling
    super(user, options.merge(:devices => []))
  end

  def title
    if self.start == self.end
      self.start.to_s
    else
      "#{self.start} through #{self.end}"
    end
  end

  def to_csv
    self.data.rename_columns(
      :name => "Group Name",
      :duration => "Operating Time (s)",
      :miles => "Miles",
      :event_speed => "Speed Events",
      :event_geofence => "Geofence Events",
      :event_idle => "Idle Events",
      :event_aggressive => "Aggressive Events",
      :event_after_hours => "After Hours Events",
      :first_start_time => "First Start Time"
    )
    super
  end

  def run
    self.data = Ruport::Data::Table(
      :name,
      :duration,
      :miles,
      :event_speed,
      :event_geofence,
      :event_idle,
      :event_aggressive,
      :event_after_hours,
      :first_start_time,
      :last_end_time
    )

    aggregate = {
      :first_start_time => [],
      :last_end_time => [],
      :duration => 0,
      :miles => 0,
      :event_speed => 0,
      :event_geofence => 0,
      :event_idle => 0,
      :event_aggressive => 0,
      :event_after_hours => 0
    }

    @group.self_and_descendants.each do |g|
      g.devices.each do |device|
        trips = device.trips.in_range(self.start, self.end, self.user.zone)

        # Do event grouping in database
        events = device.events.in_range(self.start, self.end, self.user.zone).all(
          :select => 'event_type, COUNT(*) AS count_all',
          :group => :event_type
        ).map {|e| [e.event_type, e.count_all.to_i]}
        
        # Hashify
        events = Hash[*events.inject([]) {|arr, elem| arr.concat(elem)}]

        aggregate[:first_start_time] << trips.first.start if trips.any?
        aggregate[:last_end_time] << trips.last.finish if trips.any?
        aggregate[:duration] += trips.map {|t| t.duration}.sum
        aggregate[:miles] += trips.map {|t| t.miles}.sum
        aggregate[:event_speed] += events[Event::SPEED] || 0
        aggregate[:event_geofence] += [
            events[Event::ENTER_BOUNDARY] || 0,
            events[Event::EXIT_BOUNDARY] || 0
          ].sum
        aggregate[:event_idle] += events[Event::IDLE] || 0
        aggregate[:event_aggressive] += [
            events[Event::RPM] || 0,
            events[Event::RAPID_ACCEL] || 0,
            events[Event::RAPID_DECEL] || 0
          ].sum
        aggregate[:event_after_hours] += events[Event::AFTER_HOURS] || 0
      end
    end

    aggregate[:first_start_time] = aggregate[:first_start_time].sort.first
    aggregate[:last_end_time] = aggregate[:last_end_time].sort.last

    self.data = aggregate.merge(:name => @group.name)
  end

end
