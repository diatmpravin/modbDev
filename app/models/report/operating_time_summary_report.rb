class OperatingTimeSummaryReport < Report

  def validate
    if(devices.blank?)
      self.errors << 'You must choose one or more vehicles to run this report' 
    end
  end

  def title
    "Operating Time Summary Report - #{self.start} through #{self.end}"
  end

  def to_csv
    self.data.rename_columns(
      :name => "Name",
      :miles => "Miles",
      :duration => "Operating Time (s)",
      :idle_time => "Idle Time (s)",
      :idle_pct => "Idle %"
    )
    super
  end

  def run
    report = Ruport::Data::Table(
      :name,
      :miles,
      :duration,
      :idle_time,
      :idle_pct
    )

    devices.each do |device|
      trips = device.trips.in_range(self.start, self.end, self.user.zone)

      report << {
        :name => device.name,
        :miles => trips.map {|t| t.miles}.sum,
        :duration => trips.map {|t| t.duration}.sum,
        :idle_time => trips.map {|t| t.idle_time}.sum
      }
    end

    self.data = report
  end

end
