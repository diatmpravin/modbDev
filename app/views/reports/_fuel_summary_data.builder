xml.graph(:caption => report.title,
          :xAxisName => 'Day',
          :yAxisName => 'MPG',
          :showValues => '0',
          :showAlternateHGridColor => '1',
          :AlternateHGridColor => '323c3e',
          :alternateHGridAlpha => '5',
          :decimalPrecision => '1',
          :formatNumberScale => '0',
          :connectNullData => '1') do

  xml.categories do
    report.dates.each do |date|
      xml.category(:name => date.strftime("%d"))
    end
  end

  report.devices.each do |device|
    xml.dataset :seriesName => device.name do
      report.dates.each do |date|
        report.mpg[date][device.name].each do |val|
          xml.set :value => val > 0.0 ? mpg_format(val) : nil
        end
      end
    end
  end

end
