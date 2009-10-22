class Report
  class DailySummaryReport < Generator
    def run
      return nil unless valid?
      
      device = Device.find(self.device)
      report = Ruport::Data::Table(
        :date,
        :miles,
        :mpg,
        :duration,
        :idle_time,
        :speed,
        :geofence,
        :idle_time,
        :aggressive,
        :after_hours
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
      events = device.events.in_range(self.start, self.end, self.account.zone).all(
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
          :mpg => "%.1f" % (mpg[index] || 0),
          :duration => duration_format(duration[index] || 0),
          :idle_time => duration_format(idle_time[index] || 0),
          :speed => events[[index, Event::SPEED]] || 0,
          :geofence => [
            events[[index, Event::ENTER_BOUNDARY]] || 0,
            events[[index, Event::EXIT_BOUNDARY]] || 0
          ].sum,
          :idle_time => events[[index, Event::IDLE]] || 0,
          :aggressive => [
            events[[index, Event::RPM]] || 0,
            events[[index, Event::RAPID_ACCEL]] || 0,
            events[[index, Event::RAPID_DECEL]] || 0
          ].sum,
          :after_hours => events[[index, Event::AFTER_HOURS]] || 0
        }
      end
      
      report
    end

    def valid?
      if(devices.blank? || devices.length != 1)
        self.errors << 'You must choose one vehicle to run this report'
      end

      self.errors.empty?
    end

    def device
      self.devices.first
    end

    def title
      "Daily Summary Report for #{self.device.name} - #{self.start} through #{self.end}"
    end
  end
end
