class DataAggregator

  def initialize
    @trips = []
    @average_mpg = BigDecimal.new("0")
  end

  def trips=(trips)
    @trips = trips
    preprocess unless @trips.empty?
  end

  # Overall average MPG for this day's driving
  def mpg
    @average_mpg.round(1)
  end

  # Total time of actual driving
  def time
    @time || 0
  end

  # Distance travelled this day
  def miles
    @miles || 0
  end

  protected
  
  def preprocess
    time = 0
    mpg = 0
    miles = 0

    @trips.each do |trip|
      time += trip.duration
      mpg += trip.average_mpg
      miles += trip.miles
    end

    @average_mpg = BigDecimal.new("#{mpg / @trips.count.to_f}")
    @time = time
    @miles = miles
  end

end
