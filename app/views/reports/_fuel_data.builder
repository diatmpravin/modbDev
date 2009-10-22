xml = Builder::XmlMarkup.new
xml.graph(:caption => report.title,
          :subcaption => "For vehicle: #{report.devices[0].name}",
          :xAxisName => 'Day',
          :SYAxisName => 'MPG',
          :PYAxisName => 'Idle Time (s)',
          :showValues => '0',
          :showAlternateHGridColor => '1',
          :AlternateHGridColor => '323c3e',
          :alternateHGridAlpha => '5',
          :decimalPrecision => '1',
          :formatNumberScale => '0') do

  xml.categories do
    report.data.each do |r|
      xml.category(:name => r[:date].strftime("%d"))
    end
  end

  xml.dataset(:seriesName => "Idle Time", :parentYAxis => 'P', :color => '323c3e', :alpha => '50') do
    report.data.each do |r|
      xml.set :value => r[:idle_time]
    end
  end

  xml.dataset(:seriesName => "MPG", :parentYAxis => 'S', :color => '318ba9') do
    report.data.each do |r|
      xml.set :value => r[:mpg]
    end
  end

end
