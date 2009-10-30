unit ||= ""
xml.graph(:caption => report.title,
          :subcaption => "For vehicle: #{report.devices[0].name} against #{series_name}",
          :xAxisName => 'Day',
          :PYAxisName => 'MPG',
          :SYAxisName => y_axis_title,
          :showValues => '0',
          :showAlternateHGridColor => '1',
          :AlternateHGridColor => '323c3e',
          :alternateHGridAlpha => '5',
          :decimalPrecision => '1',
          :formatNumberScale => '0',
          :connectNullData => '1') do

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
      value = r[:mpg] > 0.0 ? mpg_format(r[:mpg]) : nil
      xml.set :value => value, :toolText => "#{r[:mpg]} MPG"
    end
  end

  xml.dataset(
    :seriesName => series_name,
    :parentYAxis => 'S',
    :color => '323c3e',
    :alpha => '50',
    :renderAs => 'COLUMN'
  ) do
    report.data.each do |r|
      value = r[:mpg] > 0.0 ? r[against] : nil
      xml.set :value => value, :toolText => "#{r[against]} #{unit}"
    end
  end


end
