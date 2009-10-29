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
    legs.map {|leg| leg.average_speed}.sum / legs.length
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
      trip.reload.update_precalc_fields
    
      trip
    else
      false
    end
  end
  
  # Take the last leg of this trip and "expand" it out into its own trip. This
  # new trip should be after this trip in the device's list of trips.
  #
  # Returns the new trip if the expand succeeded, false otherwise.
  def expand
    return false if legs.length < 2
    
    trip = device.trips.create
    trip.legs << legs.last
    trip.tags = self.tags
    trip.update_precalc_fields
    
    self.legs.reload
    self.update_precalc_fields
    
    trip
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
  
  # Update any precalc fields on this trip
  def update_precalc_fields(do_save = true)
    self.start = legs.first.start
    self.finish = legs.last.finish
    self.miles = legs.sum(:miles)
    self.idle_time = legs.sum(:idle_time)
    self.average_mpg = compute_average_mpg
    self.save if do_save
  end
  
  protected
  def compute_average_mpg
    return legs.first.average_mpg if legs.length < 2
    
    sum = 0
    in_leg_duration = 0
    legs.each do |leg|
      sum += leg.duration * leg.average_mpg
      in_leg_duration += leg.duration
    end
    
    sum / in_leg_duration
  end
end
