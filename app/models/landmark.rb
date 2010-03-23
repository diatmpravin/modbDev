class Landmark < ActiveRecord::Base
  belongs_to :account
  
  has_many :device_group_links, :as => :link
  has_many :device_groups, :through => :device_group_links

  validates_presence_of :name
  validates_length_of :name, :maximum => 30, :allow_nil => true, :allow_blank => true
  validates_presence_of :latitude
  validates_numericality_of :latitude, :allow_nil => true
  validates_presence_of :longitude
  validates_numericality_of :longitude, :allow_nil => true
  
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
end
