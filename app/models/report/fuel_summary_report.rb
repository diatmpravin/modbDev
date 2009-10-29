class FuelSummaryReport < Report

  attr_accessor :mpg

  def initialize(user, opts = {})
    super
    @dates = []
    @mpg = {}
  end

  def dates
    @dates.uniq
  end

  def validate
    if devices.blank?
      self.errors << 'You must choose one or more vehicles to run this report' 
    end
  end

  def title
    "Fuel Economy Summary Report - #{self.start} through #{self.end}"
  end

  def to_csv
    self.data.rename_columns(
      :name => "Name",
      :date => "Date",
      :mpg => "MPG"
    )
    super
  end

  def run
    self.data = Ruport::Data::Table(:name, :date, :mpg)

    date_conditions =  ['DATE(start) BETWEEN ? AND ?', self.start.to_s(:db), self.end.to_s(:db)]

    devices.each do |device|

      mpg_list = device.trips.average(
        :average_mpg,
        :group => 'DATE(start)',
        :conditions => date_conditions)

      Range.new(self.start, self.end).each do |date|
        index = date.to_s(:db)

        mpg = mpg_list[index] || 0

        self.data << {
          :name => device.name,
          :date => date,
          :mpg => mpg
        } if date <= self.today

        @dates << date

        @mpg[device.name] ||= []
        @mpg[device.name] << mpg
      end
    end
  end

end
