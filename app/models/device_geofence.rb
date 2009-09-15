class DeviceGeofence < ActiveRecord::Base
  belongs_to :device
  belongs_to :geofence
  
  attr_accessible :device, :geofence
end
