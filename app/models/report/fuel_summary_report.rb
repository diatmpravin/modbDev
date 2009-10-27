class FuelSummaryReport < Report

  class ReportData

    attr_accessor :report, :data

    def initialize
      @tables = []
      @devices = []
      @dates = []
      @data = {}
    end

    def <<(data)
      @report << data

      @dates << data[:date]
      @devices << data[:name]

      @data[data[:name]] ||= []
      @data[data[:name]] << data[:mpg]
    end

    def dates
      @dates.uniq
    end

    def devices
      @devices.uniq
    end

    def to_csv
      @report.to_csv
    end

  end

  def run
    self.data = ReportData.new
    self.data.report = Ruport::Data::Table(:name, :date, :mpg)

    date_conditions =  ['DATE(start) BETWEEN ? AND ?', self.start.to_s(:db), self.end.to_s(:db)]

    devices.each do |device|

      mpg = device.trips.average(
        :average_mpg,
        :group => 'DATE(start)',
        :conditions => date_conditions)

      Range.new(self.start, self.end).each do |date|
        index = date.to_s(:db)
        data << {
          :name => device.name,
          :date => date,
          :mpg => "%.1f" % (mpg[index] || 0)
        }
      end
    end
  end

  def validate
    if(devices.blank?)
      self.errors << 'You must choose one or more vehicles to run this report' 
    end
  end

  def title
    "Fuel Economy Summary Report - #{self.start} through #{self.end}"
  end

end
