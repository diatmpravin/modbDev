class Report
  class FuelEconomyReport < Generator

    def title
      "Fuel Economy Report"
    end

    def run
      return nil unless valid?

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

      Range.new(self.start, self.end).each do |date|
        index = date.to_s(:db)

        report << { 
          :date => date, 
          :mpg => "%.1f" % (mpg[index] || 0),
          :idle_time => (idle_time[index] || 0).to_i
        }
      end

      report
    end

    def device
      self.devices.first
    end

    def valid?
      if(devices.blank? || devices.length != 1)
        self.errors << 'You must choose one vehicle to run this report'
      end

      self.errors.empty?
    end
  end
end
