require 'test_helper'

describe "User", ActiveSupport::TestCase do
  setup do
    @account = accounts(:quentin)
    @user = users(:quentin)
    @child = users(:child)
  end
  
  context "Associations" do
    specify "belongs to an account" do
      @user.account.should.equal accounts(:quentin)
    end
    
    specify "has many devices" do
      @user.devices.should.equal [devices(:quentin_device)]
    end
  end
  
  specify "acts as tree" do
    @user.parent.should.be.nil
    @user.children.should.equal [@child]
    
    @child.parent.should.equal @user
    @child.children.should.equal []
  end
  
  context "Validations" do
    specify "requires an account" do
      @user.should.be.valid
      @user.account = nil
      @user.should.not.be.valid
    end
  end
  
  context "Authentication" do
    def create_user(options = {})
      record = User.new({ :login => 'quire', :email => 'quire@example.com', :password => 'quire', :password_confirmation => 'quire' }.merge(options))
      record.account = accounts(:quentin)
      record.save
      record
    end
    
    specify "should create user" do
      assert_difference 'User.count' do
        user = create_user
        assert !user.new_record?, "#{user.errors.full_messages.to_sentence}"
      end
    end
    
    specify "should require login" do  
      assert_no_difference 'User.count' do
        u = create_user(:login => nil)
        assert u.errors.on(:login)
      end
    end

    specify "should require password" do
      assert_no_difference 'User.count' do
        u = create_user(:password => nil)
        assert u.errors.on(:password)
      end
    end

    specify "should require password confirmation" do
      assert_no_difference 'User.count' do
        u = create_user(:password_confirmation => nil)
        assert u.errors.on(:password_confirmation)
      end
    end

    specify "should require email" do
      assert_no_difference 'User.count' do
        u = create_user(:email => nil)
        assert u.errors.on(:email)
      end
    end

    specify "should reset password" do
      users(:quentin).update_attributes(
        :password => 'new password',
        :password_confirmation => 'new password',
        :current_password => 'test'
      )
      assert_equal users(:quentin), User.authenticate(@account, 'quentin', 'new password')
    end

    specify "should not rehash password" do
      users(:quentin).update_attributes(:login => 'quentin2')
      assert_equal users(:quentin), User.authenticate(@account, 'quentin2', 'test')
    end

    specify "should authenticate user" do
      assert_equal users(:quentin), User.authenticate(@account, 'quentin', 'test')
    end

    specify "should set remember token" do
      users(:quentin).remember_me
      assert_not_nil users(:quentin).remember_token
      assert_not_nil users(:quentin).remember_token_expires_at
    end

    specify "should unset remember token" do
      users(:quentin).remember_me
      assert_not_nil users(:quentin).remember_token
      users(:quentin).forget_me
      assert_nil users(:quentin).remember_token
    end

    specify "should remember me for one week" do
      before = 1.week.from_now.utc
      users(:quentin).remember_me_for 1.week
      after = 1.week.from_now.utc
      assert_not_nil users(:quentin).remember_token
      assert_not_nil users(:quentin).remember_token_expires_at
      assert users(:quentin).remember_token_expires_at.between?(before, after)
    end

    specify "should remember me until one week" do
      time = 1.week.from_now.utc
      users(:quentin).remember_me_until time
      assert_not_nil users(:quentin).remember_token
      assert_not_nil users(:quentin).remember_token_expires_at
      assert_equal users(:quentin).remember_token_expires_at, time
    end

    specify "should remember me default two weeks" do
      before = 2.weeks.from_now.utc
      users(:quentin).remember_me
      after = 2.weeks.from_now.utc
      assert_not_nil users(:quentin).remember_token
      assert_not_nil users(:quentin).remember_token_expires_at
      assert users(:quentin).remember_token_expires_at.between?(before, after)
    end
    
    specify "requires the current password to change password" do
      user = users(:quentin)
      
      user.should.not.update_attributes(
        :password => 'test2', :password_confirmation => 'test2'
      )
      user.errors.on(:current_password).should =~ /is not correct/
      
      user.should.update_attributes(
        :password => 'test2',
        :password_confirmation => 'test2',
        :current_password => 'test'
      )
    end
    
    specify "requires current password to change email" do
      user = users(:quentin)
      
      user.should.not.update_attributes(
        :email => 'hello@hello.com'
      )
      user.errors.on(:current_password).should =~ /is not correct/
      
      user.should.update_attributes(
        :email => 'hello@hello.com', :current_password => 'test'
      )
    end
  end
  
  context "Resetting Password" do
    specify "forgotten password generates a reset code and sends an email" do
      Mailer.deliveries.clear
      @user.password_reset_code.should.be.nil
      
      @user.forgot_password
      
      @user.password_reset_code.should.not.be.nil
      Mailer.deliveries.length.should.be 1
      Mailer.deliveries.clear
    end
  end
  
  context "Time Zone" do
    specify "validates time zone" do
      @user.time_zone = 'Central Time (US & Canada)'
      @user.should.save
      
      @user.time_zone = 'Not a real time zone'
      @user.should.not.save
      @user.errors.on(:time_zone).should.equal 'is not included in the list'
    end
    
    specify "has a shortcut for its zone object" do
      @user.time_zone = 'Eastern Time (US & Canada)'
      @user.zone.name.should.equal 'Eastern Time (US & Canada)'
    end
  end
  
  specify "will promote users when destroyed" do
    new_user = @user.children.build(
      :account => @account,
      :login => 'guybrush',
      :name => 'Guybrush Threepwood',
      :email => 'guy@guy.com',
      :password => 'password',
      :password_confirmation => 'password'
    )
    new_user.should.save
    
    child_user = new_user.children.build(
      :account => @account,
      :login => 'oranges',
      :name => 'Oswald Orange',
      :email => 'oswald@orange.com',
      :password => 'password',
      :password_confirmation => 'password'
    )
    child_user.should.save
    
    child_user.parent.should.equal new_user
    new_user.parent.should.equal @user
    
    new_user.destroy
    
    child_user.reload.parent.should.equal @user
    @user.children.should.include(child_user)
  end
end
