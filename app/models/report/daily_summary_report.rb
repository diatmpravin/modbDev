class DailySummaryReport < Report

  def validate
    if(devices.blank? || devices.length != 1)
      self.errors << 'You must choose one vehicle to run this report'
    end
  end

  def device
    self.devices.first
  end

  def title
    "Daily Summary Report for #{self.device.name} - #{self.start} through #{self.end}"
  end

  def to_csv
    self.data.rename_columns(
      :date => "Date",
      :miles => "Miles",
      :mpg => "MPG",
      :duration => "Operating Time (s)",
      :idle_time => "Idle Time (s)",
      :event_speed => "Speed Events",
      :event_geofence => "Geofence Events",
      :event_idle => "Idle Events",
      :event_aggressive => "Aggressive Events",
      :event_after_hours => "After Hours Events"
    )
    super
  end

  def run
    device = Device.find(self.device)
    report = Ruport::Data::Table(
      :date,
      :miles,
      :mpg,
      :duration,
      :idle_time,
      :event_speed,
      :event_geofence,
      :event_idle,
      :event_aggressive,
      :event_after_hours
    )

    # Get info for each day, relying on database calc wherever possible
    date_conditions = [
      'DATE(start) BETWEEN ? AND ?', self.start.to_s(:db), self.end.to_s(:db)
    ]
    
    miles = device.trips.sum(:miles, :group => 'DATE(start)',
      :conditions => date_conditions)

    mpg = device.trips.average(:average_mpg, :group => 'DATE(start)',
      :conditions => date_conditions)
    
    duration = device.trips.sum('TIME_TO_SEC(TIMEDIFF(finish, start))', :group => 'DATE(start)',
      :conditions => date_conditions)
    
    idle_time = device.trips.sum(:idle_time, :group => 'DATE(start)',
      :conditions => date_conditions)
    
    # Do event grouping in database
    events = device.events.in_range(self.start, self.end, self.user.zone).all(
      :select => 'DATE(events.occurred_at) AS date, event_type, COUNT(*) AS count_all',
      :group => 'DATE(events.occurred_at), event_type'
    ).map {|e| [[e.date, e.event_type], e.count_all.to_i]}
    
    # Hashify
    events = Hash[*events.inject([]) {|arr, elem| arr.concat(elem)}]
    
    # Package up the info by date
    Range.new(self.start, self.end).each do |date|
      index = date.to_s(:db)
      
      report << {
        :date => date,
        :miles => miles[index] || 0,
        :mpg => mpg[index] || 0,
        :duration => (duration[index] || 0).to_i,
        :idle_time => (idle_time[index] || 0).to_i,
        :event_speed => events[[index, Event::SPEED]] || 0,
        :event_geofence => [
          events[[index, Event::ENTER_BOUNDARY]] || 0,
          events[[index, Event::EXIT_BOUNDARY]] || 0
        ].sum,
        :event_idle => events[[index, Event::IDLE]] || 0,
        :event_aggressive => [
          events[[index, Event::RPM]] || 0,
          events[[index, Event::RAPID_ACCEL]] || 0,
          events[[index, Event::RAPID_DECEL]] || 0
        ].sum,
        :event_after_hours => events[[index, Event::AFTER_HOURS]] || 0
      }
    end

    self.data = report
  end

end
