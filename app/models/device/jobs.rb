# Resque Jobs management
class Device < ActiveRecord::Base

  # Find all trips for the given day and calculate all relevant data
  # for that day
  def calculate_data_for(day)
    start = day.beginning_of_day.in_time_zone(self.zone)
    finish = day.end_of_day.in_time_zone(self.zone)

    day_trips = self.trips.in_range(start, finish, self.zone)

    # Do event grouping in database
    events = self.events.in_range(start, finish, self.zone).all(
      :select => 'event_type, COUNT(*) AS count_all',
      :group => :event_type
    ).map {|e| [e.event_type, e.count_all.to_i]}
    
    # Hashify
    events = Hash[*events.inject([]) {|arr, elem| arr.concat(elem)}]

    first_start_time = day_trips.any? ? day_trips.first.start : nil
    last_end_time = day_trips.any? ? day_trips.last.finish : nil
    first_start = day_trips.any? ? day_trips.first.start - start : nil
    last_stop = day_trips.any? ? finish - day_trips.last.finish : nil

    self.daily_data.create(
      :date => day.to_date,
      :time_zone => self.time_zone,
      :miles => day_trips.map {|t| t.miles}.sum,
      :duration => day_trips.map {|t| t.duration}.sum,
      :mpg => day_trips.size > 0 ? day_trips.map {|t| t.average_mpg}.sum / day_trips.size.to_f : 0,
      :speed_events => events[Event::SPEED] || 0,
      :geofence_events => [
        events[Event::ENTER_BOUNDARY] || 0,
        events[Event::EXIT_BOUNDARY] || 0
      ].sum,
      :idle_events => events[Event::IDLE] || 0,
      :aggressive_events => [
        events[Event::RPM] || 0,
        events[Event::RAPID_ACCEL] || 0,
        events[Event::RAPID_DECEL] || 0
      ].sum,
      :after_hours_events => events[Event::AFTER_HOURS] || 0,
      :first_start_time => first_start_time,
      :last_end_time => last_end_time,
      :first_start => first_start,
      :last_stop => last_stop
    )
  end

  # Enqueue a job to run daily data calculations
  def self.async_daily_data(date)
    Resque.enqueue(CalculateDailyData, date.to_s)
  end
  
  # Resque Job that takes a date and
  # runs the above method on all vehicles for the given date
  # if they need it
  class CalculateDailyData
    @queue = :data

    # TODO Find a way to check the non-existence of daily data
    # in the sql query
    def self.perform(date_str)
      date = Date.parse(date_str)
      Device.find_each do |d|
        next if d.daily_data.for(date).any?

        d.calculate_data_for(date)
      end
    end
  end
end
