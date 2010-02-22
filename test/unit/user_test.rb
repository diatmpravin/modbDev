require 'test_helper'

describe "User", ActiveSupport::TestCase do
  setup do
    @account = accounts(:quentin)
    @user = users(:quentin)
  end
  
  context "Associations" do
    specify "belongs to an account" do
      @user.account.should.equal accounts(:quentin)
    end
    
    specify "has many devices" do
      @user.devices.should.equal [devices(:quentin_device)]
    end
    
    specify "belongs to a device group" do
      @user.update_attributes(:device_group => groups(:north))
      @user.reload.device_group.should.equal groups(:north)
    end
  end
  
  context "Validations" do
    specify "requires login" do
      @user.should.be.valid
      
      @user.login = nil
      @user.should.not.be.valid
      assert @user.errors.on(:login)
    end
    
    specify "enforces uniqueness of login" do
      user = @account.users.new(:login => 'quentin')
      user.should.not.be.valid
      user.errors.on(:login).should =~ /already been taken/
    end
    
    specify "requires name" do
      @user.should.be.valid
      
      @user.name = nil
      @user.should.not.be.valid
      assert @user.errors.on(:name)
    end
    
    specify "requires email" do
      @user.should.be.valid
      
      @user.email = nil
      @user.should.not.be.valid
      assert @user.errors.on(:email)
    end
    
    specify "requires password confirmation IF password provided" do
      @user.password_confirmation = nil
      @user.should.be.valid
      
      @user.password = 'elephants'
      @user.should.not.be.valid
      assert @user.errors.on(:password_confirmation)
    end
  end
  
  context "Requiring Current Password" do
    setup do
      @user.require_current_password = true
    end
    
    specify "requires the current password to change password" do
      @user.should.not.update_attributes(
        :password => 'test2', :password_confirmation => 'test2'
      )
      @user.errors.on(:current_password).should =~ /is not correct/
      
      @user.should.update_attributes(
        :password => 'test2',
        :password_confirmation => 'test2',
        :current_password => 'test'
      )
    end
    
    specify "requires current password to change email" do
      @user.should.not.update_attributes(
        :email => 'hello@hello.com'
      )
      @user.errors.on(:current_password).should =~ /is not correct/
      
      @user.should.update_attributes(
        :email => 'hello@hello.com', :current_password => 'test'
      )
    end
  end

  context "Authentication" do
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
    
    specify "can reset passsword" do
      @user.update_attributes(
        :password => 'new password',
        :password_confirmation => 'new password'
      )
      assert_equal users(:quentin), User.authenticate(@account, 'quentin', 'new password')
    end
  end
  
  context "Setting Password" do
    specify "creating a new user sends a set password email" do
      Mailer.deliveries.clear
      
      new_user = accounts(:quentin).users.build(
        :login => 'jeff',
        :name => 'Jeffrey Lebowski',
        :email => 'jeff@jeff.com'
      )
      
      new_user.should.save
      new_user.password_reset_code.should.not.be.nil
      Mailer.deliveries.length.should.be 1
    end
    
    specify "setting a password works" do
      @user.set_password('bogus', 'boguser')
      @user.crypted_password.should.be.nil
      @user.password_reset_code.should.be.nil
      @user.password.should.equal 'bogus'
      @user.password_confirmation.should.equal 'boguser'
    end
    
    specify "locking a password works" do
      @user.password = 'test'
      @user.should.be.authenticated(@user.password)
      
      @user.lock_password
      @user.should.not.be.authenticated(@user.password)
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
  
  specify "allows device_group_id=, but enforces account ownership and group type" do
    @user.update_attributes(:device_group_id => groups(:north).id)
    
    # Wrong group type
    should.raise(ActiveRecord::RecordNotFound) do
      @user.update_attributes(:device_group_id => groups(:west).id)
    end
    
    # Wrong account
    bad = accounts(:aaron).groups.of_devices.create!(:name => 'Aaron Group')
    should.raise(ActiveRecord::RecordNotFound) do
      @user.update_attributes(:device_group_id => bad.id)
    end
  end
  
  context "User Roles" do
    specify "can assign and access user roles as an array" do
      @user.roles = [User::Role::USERS, User::Role::FLEET]
      @user.roles.should.equal [User::Role::USERS, User::Role::FLEET].sort
    
      @user.update_attributes(:roles => [User::Role::USERS, User::Role::FLEET])
      @user.reload.roles.should.equal [User::Role::USERS, User::Role::FLEET].sort
    end
    
    specify "if a user has ADMIN role, they have ALL roles" do
      @user.roles = [User::Role::ADMIN]
      
      assert @user.roles.include?(User::Role::ADMIN)
      assert @user.roles.include?(User::Role::RESELLER)
      assert @user.roles.include?(User::Role::BILLING)
      assert @user.roles.include?(User::Role::USERS)
      assert @user.roles.include?(User::Role::FLEET)
      
      assert @user.has_role?(User::Role::ADMIN)
      assert @user.has_role?(User::Role::RESELLER)
      assert @user.has_role?(User::Role::BILLING)
      assert @user.has_role?(User::Role::USERS)
      assert @user.has_role?(User::Role::FLEET)
    end
    
    specify "a user's assignble roles should never include admin" do
      @user.roles = [User::Role::ADMIN]
      
      assert !@user.assignable_roles.include?(User::Role::ADMIN)
      assert @user.assignable_roles.include?(User::Role::FLEET)
    end
    
    specify "a user's assignable roles should include reseller ONLY if account is a reseller" do
      @user.roles = [User::Role::ADMIN]
      assert @user.assignable_roles.include?(User::Role::RESELLER)
      
      @account.update_attribute(:reseller, false)
      assert !@user.reload.assignable_roles.include?(User::Role::RESELLER)
    end
  end
  
  specify "a user can not edit him/herself" do
    assert !@user.can_edit?(@user)
  end
  
  specify "a user can edit a device if it is in the right group" do
    # Ensure nested sets are working
    Group.rebuild!
    
    # User with no group can edit all vehicles
    @device = devices(:quentin_device)
    assert @user.can_edit?(@device)
    
    # User with a group can't edit this vehicle
    @user.update_attributes(:device_group => groups(:north))
    assert !@user.can_edit?(@device)
    
    # Device is in the user's assigned group
    @device.update_attributes(:groups => [groups(:north)])
    assert @user.can_edit?(@device)
    
    # Device is in a subgroup of the user's assigned group
    group = @account.groups.of_devices.create(:name => 'North Child')
    group.move_to_child_of(groups(:north))
    @device.update_attributes(:groups => [group])
    assert @user.can_edit?(@device)
  end
end

