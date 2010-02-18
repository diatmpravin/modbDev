require 'test_helper'

describe "PhonesController", ActionController::TestCase do
  use_controller PhonesController

  setup do
    login_as :quentin
  end

  context "Downloading phone software" do
    specify "works" do
      SmsNotifier.expects(:deliver_sms_message).with { |recip, msg, sender|
        recip == '6165551212@messaging.sprintpcs.com'
      }
      
      put :download, {
        :phone_number => '6165551212',
        :phone_carrier => 'sprint'
      }
      
      json['status'].should.equal 'success'
    end
    
    specify "displays an error if phone number invalid" do
      SmsNotifier.expects(:deliver_sms_message).never
      
      put :download, {
        :phone_number => '123',
        :phone_carrier => 'sprint'
      }
      
      json['status'].should.equal 'failure'
      json['error'].should.not.be.nil
    end
  end
end
