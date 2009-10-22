class Leg < ActiveRecord::Base
  belongs_to :trip
  has_many :points, :order => 'occurred_at ASC'
  
  attr_accessible :trip
end
