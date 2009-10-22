xml = Builder::XmlMarkup.new
xml.graph(:caption => report.title,
          :subcaption => "For vehicle: #{report.devices[0].name}",
          :xAxisName => 'Day',
          :yAxisName => 'MPG',
          :showValues => '0',
          :showAlternateHGridColor => '1',
          :AlternateHGridColor => 'ff5904',
          :alternateHGridAlpha => '5',
          :decimalPrecision => '1',
          :formatNumberScale => '0') do

  report.data.each do |r|
    xml.set(:name => r[:date], :value => r[:mpg])
  end
end
