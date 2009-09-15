class DeviceAlertRecipient < ActiveRecord::Base
  belongs_to :device
  belongs_to :alert_recipient
  
  attr_accessible :device, :alert_recipient
end