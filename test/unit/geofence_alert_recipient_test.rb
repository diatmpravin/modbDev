require 'test_helper'

describe "Geofence Alert Recipient", ActiveSupport::TestCase do
  setup do
    @geofence = geofences(:quentin_geofence)
    @recipient = alert_recipients(:quentin_recipient)
  end
  
  context "Associations" do
    specify "belongs to a geofence" do
      GeofenceAlertRecipient.new.should.respond_to(:geofence)
      geofence_alert_recipients(:quentin_gar).geofence.should.equal @geofence
    end
    
    specify "belongs to an alert recipient" do
      GeofenceAlertRecipient.new.should.respond_to(:alert_recipient)
      geofence_alert_recipients(:quentin_gar).alert_recipient.should.equal @recipient
    end
  end
  
  specify "protects appropriate attributes" do
    gar = GeofenceAlertRecipient.new(:geofence_id => @geofence.id, :alert_recipient_id => @recipient.id)
    gar.geofence_id.should.be.nil
    gar.alert_recipient_id.should.be.nil
    
    gar = GeofenceAlertRecipient.new(:geofence => @geofence, :alert_recipient => @recipient)
    gar.geofence_id.should.equal @geofence.id
    gar.alert_recipient_id.should.equal @recipient.id
  end
end
