# Used by the report card page, this is very close to a copy of the VehicleSummaryReport
# but with a few important changes.
#
# TODO Find a way to clean up this duplication
class VehicleReportCard < Report

  attr_accessor :device

  def initialize(user, options = {})
    @device = options.delete(:device)
    options[:devices] = [@device]

    super(user, options)
  end

  def title
    "Group Vehicles Report - #{self.start} through #{self.end}"
  end

  def run
    #report = Ruport::Data::Table(
    #  :name,
    #  :duration,
    #  :miles,
    #  :mpg,
    #  :speed_events,
    #  :geofence_events,
    #  :idle_events,
    #  :aggressive_events,
    #  :after_hours_events,
    #  :first_start,
    #  :last_stop
    #)

    #days = (self.end - self.start).to_i + 1

    #devices.each do |device|
      data = @device.daily_data_over(self.start, self.end)[0]

      tmp = {
        :name => @device.name,
        :miles => data.miles_avg.to_f,
        :duration => data.duration_avg.to_i,
        :mpg => data.mpg_avg.to_f,
        :speed_events => data.speed_events_avg.to_i,
        :geofence_events => data.geofence_events_avg.to_i,
        :idle_events => data.idle_events_avg.to_i,
        :aggressive_events => data.aggressive_events_avg.to_i,
        :after_hours_events => data.after_hours_events_avg.to_i,
        :first_start => data.first_start_avg.to_i,
        :last_start => data.last_stop_avg.to_i,
        :report_card => {}
      }

      DeviceGroup::Grade::VALID_PARAMS.each do |param|
        tmp[:report_card][param] =
          case @device.group.grade(param, tmp[param])
          when DeviceGroup::Grade::PASS
            "pass"
          when DeviceGroup::Grade::WARN
            "warn"
          when DeviceGroup::Grade::FAIL
            "fail"
          end
      end

      #report << tmp
    #end

    #self.data = report
    tmp
  end

end
