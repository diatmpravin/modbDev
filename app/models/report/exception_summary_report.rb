class ExceptionSummaryReport < Report

  def validate
    if(devices.blank?)
      self.errors << 'You must choose one or more vehicles to run this report' 
    end
  end

  def title
    "Exception Detail Report - #{self.start} through #{self.end}"
  end

  def to_csv
    self.data.rename_columns(
      :vehicle => "Vehicle",
      :date => "Date",
      :time => "Time",
      :event => "Event",
      :detail => "Detail"
    )
    super
  end

  def run
    report = Ruport::Data::Table(
      :vehicle,
      :date,
      :time,
      :event,
      :detail
    )

    devices.each do |device|
      events = device.events.in_range(self.start, self.end, self.user.zone).all(
        :include => :point
      )
      
      events.each do |event|
        time = event.occurred_at.in_time_zone(self.user.zone)
        
        report << {
          :vehicle => device.name,
          :date => time.to_date,
          :time => time.to_s(:local),
          :event => Event::TEXT[event.event_type],
          :detail => case event.event_type
                     when Event::SPEED
                       event.point.speed
                     when Event::RPM
                       event.point.rpm
                     when Event::ENTER_LANDMARK, Event::EXIT_LANDMARK
                       event.geofence_name
                     when Event::ENTER_BOUNDARY, Event::EXIT_BOUNDARY
                       event.geofence_name
                     else
                       ''
                     end
        }
      
      end
    end

    self.data = report
  end
end
