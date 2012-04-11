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
    Mailer.deliveries.first.subject.should.equal 'Teleweave: Forgotten Password'
    Mailer.deliveries.first.body.should =~ 'http://localhost:3000/users/reset_password/filet-o-fish'
  end
  
  specify "set password" do
    @user = users(:quentin)
    
    @user.update_attribute(:password_reset_code, 'quarter_pounder')
    Mailer.deliver_set_password(@user)
    
    Mailer.deliveries.length.should.be 1
    Mailer.deliveries.first.to.should.equal ['quentin@example.com']
    Mailer.deliveries.first.subject.should.equal 'Teleweave: Welcome'
    Mailer.deliveries.first.body.should =~ 'http://localhost:3000/users/set_password/quarter_pounder'
  end
  
  specify "new invoice" do
    @account = accounts(:quentin)
    @user = users(:quentin)
    @users = [@user]

    Mailer.deliver_new_invoice(@account, @users)

    Mailer.deliveries.length.should.be 1
    Mailer.deliveries.first.to.should.equal ['quentin@example.com']
    Mailer.deliveries.first.subject.should.equal 'Teleweave: Billing - New Invoice'
    Mailer.deliveries.first.body.should =~ 'http://localhost:3000/invoices'
  end

  specify "email alert" do
    Mailer.deliver_email_alert('filet@fish.com', 'test alert')
    
    Mailer.deliveries.length.should.be 1
    Mailer.deliveries.first.to.should.equal ['filet@fish.com']
    Mailer.deliveries.first.subject.should.equal 'Teleweave Alert'
    Mailer.deliveries.first.body.should =~ /test alert/
  end

  specify "can send an email on exceptions" do
    exception = nil
    # To ensure we have a backtrace
    begin; raise Exception.new("Danger Will Robinson!"); rescue Exception => ex; exception = ex; end

    Mailer.deliver_exception_thrown(exception)
    
    Mailer.deliveries.length.should.be 1
    Mailer.deliveries.first.to.should.equal ['dev@crayoninterface.com']
    Mailer.deliveries.first.subject.should.match(/\[Teleweave Test\]/)
    Mailer.deliveries.first.body.should.match(/Danger Will Robinson!/)
  end
  
  specify "can send an email on exceptions with extra message" do
    exception = nil
    # To ensure we have a backtrace
    begin; raise Exception.new("Danger Will Robinson!"); rescue Exception => ex; exception = ex; end
      
    Mailer.deliver_exception_thrown(ex, "Running tests!")
    
    Mailer.deliveries.length.should.be 1
    Mailer.deliveries.first.to.should.equal ['dredge999@gmail.com']
    Mailer.deliveries.first.subject.should.match(/\[Teleweave Test\]/)
    Mailer.deliveries.first.body.should.match(/Danger Will Robinson!/)
    Mailer.deliveries.first.body.should.match(/Running tests/)
  end
  
end
