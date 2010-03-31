class LandmarkByLandmarkSummaryReport < Report

  def validate
    if(landmarks.blank?)
      self.errors << 'You must choose one or more landmarks to run this report' 
    end
  end

  def title
    "Landmark Summary Report - #{self.start} through #{self.end}"
  end

  def to_csv
    self.data.rename_columns(
      :landmark => "Landmark",
      :name => "Name",
      :arrival_date => "Arrival Date",
      :arrival_time => "Arrival Time",
      :departure_date => "Departure Date",
      :departure_time => "Departure Time",
      :stop_time => "Stop Time"
    )
    super
  end

  def run
    report = Ruport::Data::Table(
      :landmark,
      :name,
      :arrival_date,
      :arrival_time,
      :departure_date,
      :departure_time,
      :stop_time
    )

    landmarks.each do |landmark|
      events = landmark.events.in_range(self.start, self.end, self.user.zone).all(
          :select => "*, devices.name AS device_name, devices.id AS device_id",
          :joins => { :point => :device }
      )

      row_partial = Hash.new

      events.each do |event|
        if event.event_type == Event::ENTER_LANDMARK          
          if row_partial[event.device_id]
            # we must have had an orphaned enter, not paired with an exit
            report << row_partial[event.device_id]
          end

          row_partial[event.device_id] = { 
                               :name => event.device_name,
                               :landmark => event.landmark.name,
                               :arrival_date => event.occurred_at.in_time_zone(self.user.zone).to_date.to_s(:default),
                               :arrival_time => event.occurred_at.in_time_zone(self.user.zone).to_s(:local),
                               :arrival => event.occurred_at.in_time_zone(self.user.zone)
                                }

        elsif event.event_type == Event::EXIT_LANDMARK
          row = row_partial[event.device_id] || Hash.new
          row.merge!( {
                      :name => event.device_name,
                      :landmark => event.landmark.name,
                      :departure_date => event.occurred_at.in_time_zone(self.user.zone).to_date.to_s(:default),
                      :departure_time => event.occurred_at.in_time_zone(self.user.zone).to_s(:local),
                      :departure => event.occurred_at.in_time_zone(self.user.zone)
                     })

          if row[:arrival]
            diff = row[:departure].to_i - row[:arrival].to_i
            row[:stop_time] = stop_time(diff)
          end

          report << row
          row_partial.delete(event.device_id)
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
