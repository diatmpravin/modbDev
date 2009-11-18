require 'test_helper'

describe "Alert Recipients Controller", ActionController::TestCase do
  use_controller AlertRecipientsController
  
  setup do
    login_as :quentin
    @account = accounts(:quentin)
  end
  
  context "Creating an alert recipient" do
    specify "displays new recipient form" do
      get :new
      
      template.should.equal 'new'
      assigns(:alert_recipient).should.not.be.nil
    end
    
    specify "works" do
      AlertRecipient.should.differ(:count).by(1) do
        put :create, {
          :alert_recipient => {
            :recipient_type => 0,
            :email => 'hello@hello.com'
          }
        }
      end
      
      json['status'].should.equal 'success'
      @account.alert_recipients.reload.last.should.be.email
      @account.alert_recipients.reload.last.email.should.equal 'hello@hello.com'
    end
    
    specify "handles errors gracefully" do
      put :create, {
        :alert_recipient => {
          :recipient_type => 0,
          :email => 'turkeys'
        }
      }
      
      json['status'].should.equal 'failure'
      json['error'].should.equal ['Email is invalid.']
    end
    
    specify "will return an EXISTING recipient if appropriate" do
      AlertRecipient.should.differ(:count).by(0) do
        put :create, {
          :alert_recipient => {
            :recipient_type => 0,
            :email => 'quentin@example.com'
          }
        }
      end
      
      json['status'].should.equal 'success'
      json['id'].should.equal alert_recipients(:quentin_recipient).id
      json['display_string'].should.equal 'quentin@example.com'
    end
  end
end
