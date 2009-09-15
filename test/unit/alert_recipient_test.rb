require 'test_helper'

describe "Alert Recipient", ActiveSupport::TestCase do
  setup do
    @account = accounts(:quentin)
    @recipient = alert_recipients(:quentin_recipient)
    @geofence = geofences(:quentin_geofence)
    @device = devices(:quentin_device)
  end
  
  context "Associations" do
    specify "belongs to an account" do
      @recipient.should.respond_to(:account)
      @recipient.account.should.equal @account
    end
    
    specify "has many geofences" do
      @recipient.should.respond_to(:geofences)
      @recipient.geofences.should.include(@geofence)
    end
    
    specify "has many devices" do
      @recipient.should.respond_to(:devices)
      @recipient.devices.should.include(@device)
    end
  end
  
  context "Scopes" do
    context "for()" do
      specify "excludes alerts already on a given object" do
        @account.alert_recipients.should.include(@recipient)
        @geofence.alert_recipients.should.include(@recipient)
        @account.alert_recipients.for(@geofence).should.not.include(@recipient)
      end
      
      specify "excludes nothing if the object is new" do
        @account.alert_recipients.for(Geofence.new).should.include(@recipient)
      end
    end
  end
  
  context "Validations" do
    specify "requires a type" do
      r = AlertRecipient.new
      r.should.not.be.valid
      r.errors.on(:recipient_type).should.equal 'can\'t be blank'
    end
    
    specify "requires an email, if appropriate" do
      @recipient.email = ''
      @recipient.should.not.be.valid
      @recipient.errors.on(:email).should.equal 'can\'t be blank'
      
      @recipient.email = nil
      @recipient.should.not.be.valid
      @recipient.errors.on(:email).should.equal 'can\'t be blank'
      
      @recipient = alert_recipients(:quentin_sms)
      @recipient.email = nil # just making sure
      @recipient.should.be.valid
    end
    
    specify "requires a valid email address" do
      @recipient.email = 'gravy@train@com'
      @recipient.should.not.be.valid
      @recipient.errors.on(:email).should.equal 'is invalid.'
      
      @recipient.email = 'normal@email.com'
      @recipient.should.be.valid
      
      @recipient = alert_recipients(:quentin_sms)
      @recipient.email = '1094t190479' # just making sure
      @recipient.should.be.valid
    end
    
    specify "requires a phone number, if appropriate" do
      @recipient = alert_recipients(:quentin_sms)
      @recipient.phone_number = ''
      @recipient.should.not.be.valid
      @recipient.errors.on(:phone_number).should.equal 'can\'t be blank'
      
      @recipient.phone_number = nil
      @recipient.should.not.be.valid
      @recipient.errors.on(:phone_number).should.equal 'can\'t be blank'
      
      @recipient = alert_recipients(:quentin_recipient)
      @recipient.phone_number = nil # just making sure
      @recipient.should.be.valid
    end
    
    specify "requires a valid phone number" do
      @recipient = alert_recipients(:quentin_sms)
      @recipient.phone_number = '300abc'
      @recipient.should.not.be.valid
      @recipient.errors.on(:phone_number).should.equal 'is invalid'
      
      @recipient.phone_number = '1234567890'
      @recipient.should.be.valid
      
      @recipient = alert_recipients(:quentin_recipient)
      @recipient.phone_number = '300abc' # just making sure
      @recipient.should.be.valid
    end
    
    specify "requires a carrier if appropriate" do
      @recipient = alert_recipients(:quentin_sms)
      @recipient.phone_carrier = ''
      @recipient.should.not.be.valid
      @recipient.errors.on(:phone_carrier).should.equal 'can\'t be blank'
      
      @recipient.phone_carrier = nil
      @recipient.should.not.be.valid
      @recipient.errors.on(:phone_carrier).should.equal 'can\'t be blank'
      
      @recipient = alert_recipients(:quentin_recipient)
      @recipient.phone_carrier = nil # just making sure
      @recipient.should.be.valid
    end
    
    specify "verifies carrier is valid" do
      @recipient = alert_recipients(:quentin_sms)
      @recipient.phone_carrier = 'filet-o-fish'
      @recipient.should.not.be.valid
      @recipient.errors.on(:phone_carrier).should.equal 'is not a valid carrier'
      
      @recipient.phone_carrier = 'alltel'
      @recipient.should.be.valid
    end
  end
  
  specify "knows if it is a phone" do
    alert_recipients(:quentin_recipient).should.not.be.phone
    alert_recipients(:quentin_sms).should.be.phone
  end
  
  specify "knows if it is an email" do
    alert_recipients(:quentin_recipient).should.be.email
    alert_recipients(:quentin_sms).should.not.be.email
  end
  
  context "Sending an alert" do
    setup do
      @mail = ActionMailer::Base
      @mail.deliveries.clear
    end
    
    specify "sends to an email address" do
      Time.freeze(Time.parse('03/25/2009 18:00:00 UTC')) do
        @recipient.alert('abcd')
        
        @mail.deliveries.length.should.be 1
        @mail.deliveries.first.to.should.equal ['quentin@example.com']
        @mail.deliveries.first.body.should.equal '02:00 PM EDT, 03-25-2009 abcd'
      end
    end
    
    specify "sends to a phone number" do
      Time.freeze(Time.parse('03/25/2009 18:00:00 UTC')) do
        @recipient = alert_recipients(:quentin_sms)
        @recipient.alert('abcd')
        
        @mail.deliveries.length.should.be 1
        @mail.deliveries.first.to.should.equal ['3135551212@messaging.sprintpcs.com']
        @mail.deliveries.first.body.should.equal '02:00 PM EDT, 03-25-2009 abcd'
      end
    end
  end
  
  specify "has the name of its carrier" do
    @recipient = alert_recipients(:quentin_sms)
    @recipient.phone_carrier = 'at&t'
    @recipient.phone_carrier_name.should.equal 'AT&T'
  end
  
  specify "formats email and phone alert recipients nicely" do
    alert_recipients(:quentin_recipient).display_string.should.equal 'quentin@example.com'
    alert_recipients(:quentin_sms).display_string.should.equal '3135551212 @ Sprint PCS'
  end
  
  context "Singleton helpers" do
    specify "has a list of valid carriers" do
      AlertRecipient.valid_carriers.should.include('at&t')
    end
  end
end
