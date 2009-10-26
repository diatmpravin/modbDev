xml.graph(:caption => report.title,
          :xAxisName => 'Day',
          :yAxisName => 'MPG',
          :showValues => '0',
          :showAlternateHGridColor => '1',
          :AlternateHGridColor => '323c3e',
          :alternateHGridAlpha => '5',
          :decimalPrecision => '1',
          :formatNumberScale => '0') do

  xml.categories do
    report.data.dates.each do |date|
      xml.category(:name => date.strftime("%d"))
    end
  end

  report.data.devices.each do |device|
    xml.dataset :seriesName => device do
      report.data.data[device].each do |val|
        xml.set :value => val
      end
    end
  end

end
