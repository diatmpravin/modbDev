class DataAggregator

  def initialize
    @points = []
  end

  def points=(points)
    @points = points
    preprocess_points unless @points.empty?
  end

  # Overall average MPG for this day's driving
  def mpg
    @average_mpg || 0
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
  
  def preprocess_points
    @trip = Trip.new
    @trip.points = @points
    @trip.update_point_data(false)

    @average_mpg = @trip.average_mpg
    @time = @trip.duration
    @miles = @trip.miles
  end

end