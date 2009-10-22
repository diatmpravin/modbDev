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

      mpg = device.trips.average(
        :average_mpg, 
        :group => 'DATE(start)',
        :conditions => [
          'DATE(start) BETWEEN ? AND ?', self.start.to_s(:db), self.end.to_s(:db)
        ])

      Range.new(self.start, self.end).each do |date|
        index = date.to_s(:db)

        report << { 
          :date => date, 
          :mpg => "%.1f" % (mpg[index] || 0)
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
