xml.graph(:caption => report.title,
          :subcaption => "For vehicle: #{report.devices[0].name}",
          :xAxisName => 'Day',
          :PYAxisName => 'MPG',
          :SYAxisName => 'Idle Time (minutes)',
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

  xml.dataset(
    :seriesName => "MPG", 
    :parentYAxis => 'P', 
    :color => '318ba9',
    :renderAs => 'LINE'
  ) do
    report.data.each do |r|
      xml.set :value => r[:mpg], :toolText => "#{r[:mpg]} MPG"
    end
  end

  xml.dataset(
    :seriesName => "Idle Time", 
    :parentYAxis => 'S', 
    :color => '323c3e', 
    :alpha => '50',
    :renderAs => 'LINE'
  ) do
    report.data.each do |r|
      formatted = duration_format(r[:idle_time])
      xml.set :value => r[:idle_time] / 60.0, 
        :toolText => "Idle for: #{formatted}",
        :displayValue => "#{formatted}",
        :showValue => r[:idle_time] > 0 ? "1" : "0"
    end
  end


end
