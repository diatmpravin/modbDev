class Landmark < ActiveRecord::Base
  belongs_to :account

  has_many :events
  
  has_many :device_group_links, :as => :link
  has_many :device_groups, :through => :device_group_links

  before_save :consolidate_device_groups

  validates_presence_of :name
  validates_length_of :name, :maximum => 30, :allow_nil => true, :allow_blank => true
  validates_presence_of :latitude
  validates_numericality_of :latitude, :allow_nil => true, :less_than_or_equal_to => 90, 
                            :greater_than_or_equal_to => -90, 
                            :message => "Latitude must be between -90 and 90"
  validates_presence_of :longitude
  validates_numericality_of :longitude, :allow_nil => true, :less_than_or_equal_to => 180,
                            :greater_than_or_equal_to => -180,
                            :message => "Longitude must be between -180 and 180"
  
  attr_accessible :account, :name, :latitude, :longitude, :radius, :alert_on_exit, 
     :alert_on_entry, :device_groups, :device_group_ids

  ##
  # Concerns
  ##
  concerned_with :sphinx

  def device_group_ids=(list)
    self.device_groups = account.device_groups.find(
      list.reject {|a| a.blank?}
    )
  end
  
  def device_group_names
    self.device_groups.map(&:name).join(', ')
  end
  
  def contain?(point)
    Haversine::distance(latitude, 
                        longitude, 
                        point.latitude,
                        point.longitude) <= radius
  end

  # Weed out group linkings that aren't necessary, because they have parents
  # that are already linked to this object.
  def consolidate_device_groups
    if self.device_groups.length > 1
      self.device_groups -= self.device_groups.map(&:descendants).flatten
    end
  end
end
