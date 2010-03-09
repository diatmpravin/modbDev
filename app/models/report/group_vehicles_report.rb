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
      :first_start_time,
      :last_end_time
    )

    devices.each do |device|
      data = device.daily_data_over(self.start, self.end)

      report << {
        :name => device.name,
        :miles => data.miles,
        :duration => data.duration,
        :event_speed => data.speed_events,
        :event_geofence => data.geofence_events,
        :event_idle => data.idle_events,
        :event_aggressive => data.aggressive_events,
        :event_after_hours => data.after_hours_events,
        :first_start_time => data.first_start_time,
        :last_end_time => data.last_end_time
      }
    end

    self.data = report
  end

end
