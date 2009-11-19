class DeviceTag < ActiveRecord::Base
  belongs_to :device
  belongs_to :tag
  
  attr_accessible :device, :tag
end
