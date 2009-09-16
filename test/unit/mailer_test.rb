require 'test_helper'

describe "Mailer", ActiveSupport::TestCase do
  setup do
    Mailer.deliveries.clear
  end
  
  specify "forgot password" do
    @user = users(:quentin)
    
    @user.update_attribute(:password_reset_code, 'filet-o-fish')
    Mailer.deliver_forgotten_password(@user)
    
    Mailer.deliveries.length.should.be 1
    Mailer.deliveries.first.to.should.equal ['quentin@example.com']
    Mailer.deliveries.first.subject.should.equal 'Fleet: Forgotten Password'
    Mailer.deliveries.first.body.should =~ 'http://localhost:3000/users/reset_password/filet-o-fish'
  end
  
  specify "email alert" do
    Mailer.deliver_email_alert('filet@fish.com', 'test alert')
    
    Mailer.deliveries.length.should.be 1
    Mailer.deliveries.first.to.should.equal ['filet@fish.com']
    Mailer.deliveries.first.subject.should.equal 'Fleet Alert'
    Mailer.deliveries.first.body.should =~ /test alert/
  end
  
  specify "account activation" do
    @account = accounts(:quentin)
    Mailer.deliver_activation(@account)
    
    Mailer.deliveries.length.should.be 1
    Mailer.deliveries.first.to.should.equal [@account.email]
    Mailer.deliveries.first.subject.should.equal 'MOBD: Account Activation'
  end
end