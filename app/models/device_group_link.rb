class DeviceGroupLink < ActiveRecord::Base
  belongs_to :device_group
  
  belongs_to :link, :polymorphic => true
  
  attr_accessible :device_group, :link, :link_type
end
