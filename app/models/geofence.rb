class Geofence < ActiveRecord::Base
  belongs_to :account
  has_many :device_geofences, :dependent => :delete_all
  has_many :devices, :through => :device_geofences
  has_many :geofence_alert_recipients, :dependent => :delete_all
  has_many :alert_recipients, :through => :geofence_alert_recipients
  
  # Coordinates are stored in the form [{:latitude => N, :longitude => N}, ...]
  serialize :coordinates, Array
  default_value_for :coordinates, Array.new
  
  attr_accessible :geofence_type, :radius, :coordinates, :devices, :device_ids,
    :account, :name, :alert_recipients, :alert_recipient_ids,
    :alert_on_exit, :alert_on_entry
  
  before_save :prepare_coordinates
  
  validates_presence_of :name
  validates_length_of :name, :maximum => 30,
    :allow_nil => true, :allow_blank => true
  validate_on_create :number_of_records
  
  module Type
    ELLIPSE = 0   # coordinates = [upper-left point, lower-right point]
    RECTANGLE = 1 # coordinates = [upper-left point, lower-right point]
    POLYGON = 2   # coordinates = [p0, p1, p2, ... pN]
  end
  
  def device_ids=(list)
    self.devices = account.devices.find(list)
  end
  
  def alert_recipient_ids=(list)
    self.alert_recipients = account.alert_recipients.find(
      list.reject {|a| a.blank?}
    )
  end
  
  def contain?(point)
    case geofence_type
      when Type::ELLIPSE
        within_ellipse?(point)
      when Type::RECTANGLE
        within_rectangle?(point)
      when Type::POLYGON
        within_polygon?(point)
      else
        false
    end
  end
  
  protected
  def prepare_coordinates
    if self[:coordinates]
      self[:coordinates] = self[:coordinates].map { |h|
        {:latitude => h[:latitude].to_f, :longitude => h[:longitude].to_f}
      }
    end
  end
  
  def within_ellipse?(point)
    c = coordinates
    
    # Get cartesian coords for the lower-right corner of the ellipse's bounding
    # rectangle and the point, fixing the upper-right corner of the ellipse
    # at 0,0.
    cornerX = Haversine::distance(
      c[0][:latitude], c[0][:longitude],
      c[0][:latitude], c[1][:longitude]
    )
    cornerY = Haversine::distance(
      c[0][:latitude], c[0][:longitude],
      c[1][:latitude], c[0][:longitude]
    )
    deltaY = Haversine::distance(
      c[0][:latitude], point.longitude,
      point.latitude, point.longitude
    )
    deltaX = Haversine::distance(
      point.latitude, c[0][:longitude],
      point.latitude, point.longitude
    )
    
    # Standard ellipse check. Note major radius = center x and minor radius =
    # center y, since the upper-left corner is always 0,0.
    centerX = cornerX / 2
    centerY = cornerY / 2
    deltaX -= centerX
    deltaY -= centerY
    
    (deltaY ** 2) / (centerY ** 2) + (deltaX ** 2) / (centerX ** 2) <= 1
  end
  
  def within_rectangle?(point)
    point.latitude >= coordinates[0][:latitude] &&
    point.latitude <= coordinates[1][:latitude] &&
    point.longitude >= coordinates[0][:longitude] &&
    point.longitude <= coordinates[1][:longitude]
  end
  
  def within_polygon?(point)
    # Get cartesian coords for the polygon points and the point to be tested
    poly_points = Haversine::ll_to_xy(
      coordinates.map {|c| [c[:latitude], c[:longitude]]} <<
        [point.latitude, point.longitude]
    )
    p = poly_points.slice!(-1)
    
    # Check each polygon line against the test point
    inside = false
    last_point = poly_points.last
    poly_points.each do |xy|
      if last_point[1] < p[1] && xy[1] >= p[1] ||
         xy[1] < p[1] && last_point[1] >= p[1]
        if xy[0] + (p[1] - xy[1]) / (last_point[1] - xy[1]) * (last_point[0] - xy[0]) < p[0]
          inside = !inside
        end
      end
      last_point = xy
    end
    
    inside
  end
  
  def number_of_records
    if Geofence.count(:conditions => {:account_id => account_id}) >= 20
      errors.add_to_base 'Too many geofences'
    end
  end
end