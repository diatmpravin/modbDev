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

  def run
    report = Ruport::Data::Table(
      :name,
      :duration,
      :miles,
      :mpg,
      :speed_events,
      :geofence_events,
      :idle_events,
      :aggressive_events,
      :after_hours_events,
      :first_start,
      :last_stop
    )

    days = (self.end - self.start).to_i + 1

    devices.each do |device|
      data = device.daily_data_over(self.start, self.end)

      tmp = {
        :name => device.name,
        :miles => data.miles,
        :duration => data.duration,
        :mpg => data.mpg,
        :speed_events => data.speed_events,
        :geofence_events => data.geofence_events,
        :idle_events => data.idle_events,
        :aggressive_events => data.aggressive_events,
        :after_hours_events => data.after_hours_events,
        :first_start => data.first_start,
        :last_start => data.last_stop,
        :report_card => {}
      }

      DeviceGroup::Grade::VALID_PARAMS.each do |param|
        tmp[:report_card][param] =
          case @group.grade(param, tmp[param])
          when DeviceGroup::Grade::PASS
            "pass"
          when DeviceGroup::Grade::WARN
            "warn"
          when DeviceGroup::Grade::FAIL
            "fail"
          end
      end

      report << tmp
    end

    self.data = report
  end

end
