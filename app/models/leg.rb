class Leg < ActiveRecord::Base
  belongs_to :trip
  has_many :points, :order => 'occurred_at ASC'
  has_many :displayable_points, :class_name => 'Point', :order => 'occurred_at ASC',
    :conditions => 'latitude <> 0 OR longitude <> 0', :include => :events, :readonly => true
  
  attr_accessible :trip, :points
  
  def duration
    if finish && start
      finish - start
    else
      0
    end
  end
  
  def max_speed
    points.maximum(:speed)
  end
  
  def average_speed
    if duration > 0
      (miles.to_f * 60 * 60 / duration).to_i
    else
      0
    end
  end
  
  def average_rpm
    points.average(:rpm).to_i
  end
  
  # Update any precalc fields on this leg, then call precalc on the trip.
  def update_precalc_fields(do_save = true)
    # TODO: Revisit "points.reload". Seems excessive, but we'll need the points
    # in compute_average_mpg anyway, so maybe it doesn't matter.
    points.reload
    
    first_point = points.first
    last_point = points.last
    if first_point && last_point
      self.start = first_point.occurred_at
      self.finish = last_point.occurred_at
      self.miles = last_point.miles - first_point.miles
      self.miles += Device::ROLLOVER_MILES if self.miles < 0
      self.idle_time = compute_idle_time
      self.average_mpg = compute_average_mpg
      self.save if do_save
    end
    
    trip.update_precalc_fields
  end
  
  protected
  def compute_idle_time
    # sum up the durations of points where speed is 0
    sum = 0
    points[0..-2].each_index do |i|
      if points[i].mpg == 0
        sum += points[i+1].occurred_at - points[i].occurred_at
      end
    end
    sum
  end
  
  def compute_average_mpg
    # return mpg from the last point that has a non-zero mpg
    points[0..-1].each_index do |i|
      idx = points.length - i - 1
      return points[idx].mpg if points[idx].mpg > 0
    end
    return 0
  end
end
