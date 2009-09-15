class TripTag < ActiveRecord::Base
  belongs_to :trip
  belongs_to :tag
  
  attr_accessible :trip, :tag
end