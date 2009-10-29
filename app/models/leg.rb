class Leg < ActiveRecord::Base
  belongs_to :trip
  has_many :points, :order => 'occurred_at ASC'
  
  attr_accessible :trip, :points
  
  def duration
    finish - start
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
    points.before(finish).sum(:duration, :conditions => {:speed => 0})
  end
  
  def compute_average_mpg
    return points[0].mpg if duration <= 0
    
    sum = 0
    points[0..-2].each_index do |i|
      sum += points[i].duration * (points[i+1].mpg + points[i].mpg) / 2
    end
    
    sum / duration
  end
end
