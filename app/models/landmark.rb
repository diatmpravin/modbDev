class Landmark < ActiveRecord::Base
  belongs_to :account
  
  validates_presence_of :name
  validates_length_of :name, :maximum => 30, :allow_nil => true, :allow_blank => true
  validates_presence_of :latitude
  validates_numericality_of :latitude, :allow_nil => true
  validates_presence_of :longitude
  validates_numericality_of :longitude, :allow_nil => true
  
  attr_accessible :account, :name, :latitude, :longitude, :radius
  
  def contain?(point)
    Haversine::distance(latitude, 
                        longitude, 
                        point.latitude,
                        point.longitude) <= radius
  end
end
