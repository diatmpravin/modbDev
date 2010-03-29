class LandmarkSummaryReport < Report

  def validate
    if(devices.blank?)
      self.errors << 'You must choose one or more vehicles to run this report' 
    end
  end

  def title
    "Landmark Summary Report - #{self.start} through #{self.end}"
  end

  def to_csv
    self.data.rename_columns(
      :name => "Name",
      :landmark => "Landmark",
      :arrival => "Arrival",
      :departure => "Departure",
      :stop_time => "Stop Time"
    )
    super
  end

  def run
    report = Ruport::Data::Table(
      :name,
      :landmark,
      :arrival,
      :departure,
      :stop_time
    )

    devices.each do |device|
      events = device.events.in_range(self.start, self.end, self.user.zone).all(
        :conditions => { :event_type => [Event::ENTER_LANDMARK,Event::EXIT_LANDMARK] }
      )

      row_partial = Hash.new

      events.each do |event|
        if event.event_type == Event::ENTER_LANDMARK          
          if row_partial[event.landmark_id]
            # we must have had an orphaned enter, not paired with an exit
            report << row_partial[event.landmark_id]
          end

          row_partial[event.landmark_id] = { 
                               :name => device.name,
                               :landmark => event.landmark.name,
                               :arrival => event.occurred_at.in_time_zone(self.user.zone)
                                }

        elsif event.event_type == Event::EXIT_LANDMARK
          row = row_partial[event.landmark_id] || Hash.new
          row.merge!( {
                      :name => device.name,
                      :landmark => event.landmark.name,
                      :departure => event.occurred_at.in_time_zone(self.user.zone)
                     })

          if row[:arrival]
            diff = row[:departure].to_i - row[:arrival].to_i
            row[:stop_time] = stop_time(diff)
          end

          report << row
          row_partial.delete(event.landmark_id)
        end
      end

      # now add any incompleted partials
      row_partial.values.each do | row |
        report << row
      end
    end

    self.data = report
  end

  def stop_time(seconds)
    [seconds/3600, seconds/60 % 60].map{|t| t.to_s.rjust(2,'0')}.join(':')
  end
end
