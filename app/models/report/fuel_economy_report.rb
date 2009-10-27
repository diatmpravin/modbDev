class FuelEconomyReport < Report

  def title
    "Fuel Economy Report"
  end

  def duration_format(seconds)
    minutes = seconds.to_i / 60
    "%02d:%02d" % [minutes / 60, minutes % 60]
  end

  def device
    self.devices.first
  end

  def validate
    if(devices.blank? || devices.length != 1)
      self.errors << 'You must choose one vehicle to run this report'
    end
  end

  def run
    device = Device.find(self.device)
    report = Ruport::Data::Table(
      :date,
      :mpg
    )

    date_conditions =  ['DATE(start) BETWEEN ? AND ?', self.start.to_s(:db), self.end.to_s(:db)]

    mpg = device.trips.average(
      :average_mpg,
      :group => 'DATE(start)',
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

    Range.new(self.start, self.end).each do |date|
      index = date.to_s(:db)

      trips = device.trips.find(:all, :conditions => ["DATE(start) = DATE(?)", date])
      rpm = trips.length > 0 ? trips.inject(0) {|memo, t| memo + t.average_rpm } / trips.length : 0

      report << {
        :date => date,
        :mpg => "%.1f" % (mpg[index] || 0),
        :idle_time => (idle_time[index] || 0).to_i / 60,
        :speed_events => events[[index, Event::SPEED]] || 0,
        :average_rpm => rpm,
        :aggresive => [
          events[[index, Event::RPM]] || 0,
          events[[index, Event::RAPID_ACCEL]] || 0,
          events[[index, Event::RAPID_DECEL]] || 0
        ].sum
      }
    end

    self.data = report
  end

end
