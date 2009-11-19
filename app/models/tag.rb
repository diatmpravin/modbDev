class Tag < ActiveRecord::Base
  belongs_to :account
  has_many :trip_tags
  has_many :trips, :through => :trip_tags
  has_many :device_tags
  has_many :devices, :through => :device_tags
  
  validates_presence_of :name
  validates_length_of :name, :maximum => 30,
    :allow_blank => true, :allow_nil => true
  
  # Return all tags NOT attached to the given object
  named_scope :for, lambda { |object|
    {
      :conditions => [
        "id NOT IN (SELECT tag_id FROM \
        #{object.class.name.downcase}_tags WHERE #{object.class.name.downcase}_id = ?)",
        object.id
      ]
    }
  }
  
  attr_accessible :name, :account, :trips, :devices
end