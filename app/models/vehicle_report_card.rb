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
      :last_stop => data.last_stop_avg.to_i,
      :report_card => {}
    }

    DeviceGroup::Grade::VALID_PARAMS.each do |param|
      # TODO: cannot currently grade a vehicle without a group!
      if @device.group.nil? 
        "pass"
      else
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
    end

    # we grade over the average, but we'll want to show the totals.
    tmp[:miles] = data.miles_sum.to_f
    tmp[:duration] = data.duration_sum.to_i
    tmp[:speed_events]  = data.speed_events_sum.to_i
    tmp[:geofence_events]  = data.geofence_events_sum.to_i
    tmp[:idle_events]  = data.idle_events_sum.to_i
    tmp[:aggressive_events]  = data.aggressive_events_sum.to_i
    tmp[:after_hours_events]  = data.after_hours_events_sum.to_i

    tmp
  end

end
