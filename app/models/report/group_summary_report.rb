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
      :mpg => "MPG",
      :miles => "Miles",
      :speed_events => "Speed Events",
      :geofence_events => "Geofence Events",
      :idle_events => "Idle Events",
      :aggressive_events => "Aggressive Events",
      :after_hours_events => "After Hours Events",
      :first_start_time => "First Start Time"
    )
    super
  end

  def run
    self.data = Ruport::Data::Table(
      :name,
      :duration,
      :miles,
      :mpg,
      :speed_events,
      :geofence_events,
      :idle_events,
      :aggressive_events,
      :after_hours_events,
      :first_start_time,
      :last_end_time
    )

    aggregate = {
      :report_card => {},
      :first_start_time => [],
      :last_end_time => [],
      :mpg => [],
      :duration => [],
      :miles => [],
      :speed_events => [],
      :geofence_events => [],
      :idle_events => [],
      :aggressive_events => [],
      :after_hours_events => [],
    }

    report_card = {
      :count => 0,
      :miles => 0,
      :duration => 0,
      :mpg => 0,
      :speed_events => 0,
      :geofence_events => 0,
      :idle_events => 0,
      :aggressive_events => 0,
      :after_hours_events => 0,
      :first_start_time => 0,
      :last_end_time => 0
    }

    days = (self.end - self.start).to_i + 1

    @group.self_and_descendants.each do |g|
      g.devices.each do |device|

        data = device.daily_data_over(self.start, self.end)

        aggregate[:first_start_time] << (data.first_start_time ? 
          data.first_start_time.in_time_zone(data.time_zone) : nil)
        aggregate[:last_end_time] << (data.last_end_time ? 
          data.last_end_time.in_time_zone(data.time_zone) : nil)

        aggregate[:mpg] << data.mpg
        aggregate[:duration] << data.duration
        aggregate[:miles] << data.miles
        aggregate[:speed_events] << data.speed_events
        aggregate[:geofence_events] << data.geofence_events
        aggregate[:idle_events] << data.idle_events
        aggregate[:aggressive_events] << data.aggressive_events
        aggregate[:after_hours_events] << data.after_hours_events

        # Report card grading
        report_card[:count] += 1
        Group::Grade::VALID_PARAMS.each do |param|
          val = aggregate[param].last
          report_card[param] +=
            case @group.grade(param, val, Group::Grade::AVERAGE_PARAMS[param] ? 1 : days)
            when Group::Grade::PASS
              1
            when Group::Grade::WARN
              0.4
            when Group::Grade::FAIL
              -1
            end
        end
      end
    end

    aggregate[:duration] = aggregate[:duration].sum
    aggregate[:miles] = aggregate[:miles].sum
    aggregate[:speed_events] = aggregate[:speed_events].sum
    aggregate[:geofence_events] = aggregate[:geofence_events].sum
    aggregate[:idle_events] = aggregate[:idle_events].sum
    aggregate[:aggressive_events] = aggregate[:aggressive_events].sum
    aggregate[:after_hours_events] = aggregate[:after_hours_events].sum

    aggregate[:first_start_time] = aggregate[:first_start_time].compact.sort.first
    aggregate[:last_end_time] = aggregate[:last_end_time].compact.sort.last

    if report_card[:count] > 0
      aggregate[:mpg] = 
        aggregate[:mpg].length > 0 ?  aggregate[:mpg].sum.to_f / aggregate[:mpg].length.to_f : 0

      Group::Grade::VALID_PARAMS.each do |param|
        score = report_card[param] / report_card[:count]
        aggregate[:report_card][param] =
          if score >= 0.8
           "pass"
          elsif score >= 0.33 && score < 0.8
            "warn"
          else
            "fail"
          end
      end
    end

    aggregate[:mpg] = 0 if aggregate[:mpg].is_a?(Array) && aggregate[:mpg].empty?

    self.data = aggregate.merge(:name => @group.name)
  end

end
