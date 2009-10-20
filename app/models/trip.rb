class Trip < ActiveRecord::Base
  belongs_to :device
  has_many :legs, :order => 'created_at'
  # NOTE: Ideally, legs would be ordered by their first point's occurred_at field.
  # This might need to become a stored fields on legs.
  has_many :points, :through => :legs, :order => 'occurred_at'
  has_many :trip_tags, :dependent => :delete_all
  has_many :tags, :through => :trip_tags, :order => 'name'
  
  # Scope only trips within the given date range
  named_scope :in_range, lambda { |start_date, end_date, zone|
    {
      :conditions => [
        '(start BETWEEN :start AND :finish) OR ' +
        '(finish BETWEEN :start AND :finish) OR ' +
        '(start < :start AND finish > :finish)',
        {
          :start => zone.parse(start_date.to_s),
          :finish => zone.parse(end_date.to_s).end_of_day
        }
      ]
    }
  }
  
  attr_accessible :device, :start, :finish, :points, :legs, :tags, :tag_ids
  
  default_value_for :start do
    Time.now.utc
  end
  
  default_value_for :finish do
    Time.now.utc
  end
  
  def tag_ids=(list)
    self.tags = device.account.tags.find(list)
  end
  
  def update_point_data(do_save = true)
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
  end
  
  def color
    device.color
  end
  
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
  
  def events
    Event.find(:all,
      :conditions => ['legs.trip_id=?', self.id],
      :joins => ' INNER JOIN points ON points.id = events.point_id' +
                ' INNER JOIN legs ON legs.id = points.leg_id')
  end
  
  # Find the trip immediately before this one in the device's list of trips,
  # then collapse this trip into it.  The new trip inherits any legs and tags
  # from this trip.
  #
  # Returns the new trip if the collapse succeeded, false otherwise.
  def collapse
    list = device.trips.all(:select => :id)
    index = list.index(self)
    
    if index && index > 0
      trip = list[index-1].reload
      
      Leg.update_all({:trip_id => trip.id}, {:trip_id => self.id})
      trip.tags = (trip.tags + self.tags).uniq
      self.reload.destroy
      trip.reload.update_point_data
    
      trip
    else
      false
    end
  end
  
  # Extend default to_json
  def to_json(options = {})
    super(options.merge(
      :include => {
        :legs => {
          :include => {
            :points => {
              :methods => [:time_of_day],
              :include => {
                :events => {
                  :methods => [:type_text]
                }
              }
            }
          }
        }
      },
      :methods => [:color]
    ))
  end
  
  protected
  def compute_idle_time
    sum = 0
    points[0..-2].each_index do |i|
      if points[i].speed == 0
        sum += points[i+1].occurred_at - points[i].occurred_at
      end
    end
    
    sum
  end
  
  def compute_average_mpg
    return points[0].mpg if duration <= 0
    
    sum = 0
    points[0..-2].each_index do |i|
      sum += (points[i+1].occurred_at - points[i].occurred_at) * (points[i+1].mpg + points[i].mpg) / 2
    end
    
    sum / duration
  end
end
