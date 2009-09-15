require 'test_helper'

describe "Mailer", ActiveSupport::TestCase do
  setup do
    Mailer.deliveries.clear
  end
  
  specify "forgot login" do
    @accounts = [accounts(:quentin)]
    Mailer.deliver_forgotten_login('filet@fish.com', @accounts)
    
    Mailer.deliveries.length.should.be 1
    Mailer.deliveries.first.to.should.equal ['filet@fish.com']
    Mailer.deliveries.first.subject.should.equal 'Mobd Forgotten Login'
  end
  
  xspecify "forgot password" do
    @account = accounts(:quentin)
    Mailer.deliver_forgotten_password(@account)
    
    assigns(:account).should.equal @account
    Mailer.deliveries.length.should.be 1
  end
  
  specify "email alert" do
    Mailer.deliver_email_alert('filet@fish.com', 'test alert')
    
    Mailer.deliveries.length.should.be 1
    Mailer.deliveries.first.to.should.equal ['filet@fish.com']
    Mailer.deliveries.first.subject.should.equal 'Mobd Alert'
    Mailer.deliveries.first.body.should =~ /test alert/
  end

  specify "account cancelled" do
    @account = accounts(:quentin)
    Mailer.deliver_account_cancelled(@account)
    
    Mailer.deliveries.length.should.be 1
    Mailer.deliveries.first.to.should.equal [@account.email]
    Mailer.deliveries.first.subject.should.equal 'MOBD: Account Cancelled'
    Mailer.deliveries.first.body.should =~ /#{@account.login}/
  end
  
  specify "account activation" do
    @account = accounts(:quentin)
    Mailer.deliver_activation(@account)
    
    Mailer.deliveries.length.should.be 1
    Mailer.deliveries.first.to.should.equal [@account.email]
    Mailer.deliveries.first.subject.should.equal 'MOBD: Account Activation'
  end
end