class GeofenceAlertRecipient < ActiveRecord::Base
  belongs_to :geofence
  belongs_to :alert_recipient
  
  attr_accessible :geofence, :alert_recipient
end