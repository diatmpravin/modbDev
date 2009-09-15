require 'test_helper'

describe "Device Alert Recipient", ActiveSupport::TestCase do
  setup do
    @device = devices(:quentin_device)
    @recipient = alert_recipients(:quentin_recipient)
  end
  
  context "Associations" do
    specify "belongs to a device" do
      DeviceAlertRecipient.new.should.respond_to(:device)
      device_alert_recipients(:quentin_dar).device.should.equal @device
    end
    
    specify "belongs to an alert recipient" do
      DeviceAlertRecipient.new.should.respond_to(:alert_recipient)
      device_alert_recipients(:quentin_dar).alert_recipient.should.equal @recipient
    end
  end
  
  specify "protects appropriate attributes" do
    dar = DeviceAlertRecipient.new(:device_id => @device.id, :alert_recipient_id => @recipient.id)
    dar.device_id.should.be.nil
    dar.alert_recipient_id.should.be.nil
    
    dar = DeviceAlertRecipient.new(:device => @device, :alert_recipient => @recipient)
    dar.device_id.should.equal @device.id
    dar.alert_recipient_id.should.equal @recipient.id
  end
end
