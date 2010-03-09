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

        data = device.daily_data_over(self.start, self.end)

        aggregate[:first_start_time] << data.first_start_time
        aggregate[:last_end_time] << data.last_end_time
        aggregate[:duration] += data.duration
        aggregate[:miles] += data.miles
        aggregate[:event_speed] += data.speed_events
        aggregate[:event_geofence] += data.geofence_events
        aggregate[:event_idle] += data.idle_events
        aggregate[:event_aggressive] += data.aggressive_events
        aggregate[:event_after_hours] += data.after_hours_events

      end
    end

    aggregate[:first_start_time] = aggregate[:first_start_time].compact.sort.first
    aggregate[:last_end_time] = aggregate[:last_end_time].compact.sort.last

    self.data = aggregate.merge(:name => @group.name)
  end

end
