class Trip < ActiveRecord::Base
  belongs_to :device
  has_many :legs
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
