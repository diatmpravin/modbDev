class Geofence < ActiveRecord::Base
  belongs_to :account

  has_many :events
  
  has_many :device_group_links, :as => :link
  has_many :device_groups, :through => :device_group_links
  
  # Coordinates are stored in the form [{:latitude => N, :longitude => N}, ...]
  serialize :coordinates, Array
  default_value_for :coordinates, Array.new
  
  # Allow access to coordinates as a comma-separated list of lats & lngs
  attr_accessor :coordinates_text
  
  attr_accessible :geofence_type, :radius, :coordinates,
    :account, :name, :alert_on_exit, :alert_on_entry,
    :device_groups, :device_group_ids, :coordinates_text
  
  before_save :consolidate_device_groups
  before_save :prepare_coordinates
  after_save :update_associated_deltas
  
  validates_presence_of :name
  validates_length_of :name, :maximum => 30,
    :allow_nil => true, :allow_blank => true
  
  ##
  # Concerns
  ##
  concerned_with :sphinx
  
  module Type
    ELLIPSE = 0   # coordinates = [upper-left point, lower-right point]
    RECTANGLE = 1 # coordinates = [upper-left point, lower-right point]
    POLYGON = 2   # coordinates = [p0, p1, p2, ... pN]
  end
  
  def device_group_ids=(list)
    self.device_groups = account.device_groups.find(
      list.reject {|a| a.blank?}
    )
  end

  def device_group_names
    self.device_groups.map(&:name).join(', ')
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
  
  def coordinates_text
    coordinates ? coordinates.map {|h| [h[:latitude], h[:longitude]]}.flatten.join(',') : ''
  end
  
  def coordinates_text=(value)
    if value
      self.coordinates = value.split(',').in_groups_of(2).map {|h|
        {:latitude => h[0], :longitude => h[1]}
      }
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
  
  def update_associated_deltas
    DeviceGroup.update_all({:delta => true}, {:id => device_groups.map(&:id)})
  end
  
  # Weed out group linkings that aren't necessary, because they have parents
  # that are already linked to this object.
  def consolidate_device_groups
    if self.device_groups.length > 1
      self.device_groups -= self.device_groups.map(&:descendants).flatten
    end
  end
end
