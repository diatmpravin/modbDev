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
      :speed_events => "Speed Events",
      :geofence_events => "Geofence Events",
      :idle_events => "Idle Events",
      :aggressive_events => "Aggressive Events",
      :after_hours_events => "After Hours Events"
    )
    super
  end

  def run
    report = Ruport::Data::Table(
      :name,
      :duration,
      :miles,
      :speed_events,
      :geofence_events,
      :idle_events,
      :aggressive_events,
      :after_hours_events,
      :first_start_time,
      :last_end_time
    )

    devices.each do |device|
      data = device.daily_data_over(self.start, self.end)

      report << {
        :name => device.name,
        :miles => data.miles,
        :duration => data.duration,
        :speed_events => data.speed_events,
        :geofence_events => data.geofence_events,
        :idle_events => data.idle_events,
        :aggressive_events => data.aggressive_events,
        :after_hours_events => data.after_hours_events,
        :first_start_time => data.first_start_time,
        :last_end_time => data.last_end_time
      }
    end

    self.data = report
  end

end
