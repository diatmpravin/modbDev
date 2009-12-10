require 'test_helper'

describe "DeviceProfile", ActiveSupport::TestCase do
  setup do
    @account = accounts(:quentin)
    @profile = device_profiles(:quentin)
    @device = devices(:quentin_device)
  end
  
  context "Associations" do
    specify "belongs to an account" do
      @profile.account.should.equal @account
    end
    
    specify "has many devices" do
      @profile.devices.all.should.include(@device)
    end
  end
  
  context "Validations" do
    specify "name must be present" do
      @profile.name = nil
      @profile.should.not.be.valid
      @profile.errors.on(:name).should.equal "can't be blank"
      
      @profile.name = ''
      @profile.should.not.be.valid
      @profile.errors.on(:name).should.equal "can't be blank"
      
      @profile.name = '1'
      @profile.should.be.valid
    end
    
    specify "name must be less than 30 characters" do
      @profile.name = '1234567890123456789012345678901'
      @profile.should.not.be.valid
      @profile.errors.on(:name).should.equal 'is too long (maximum is 30 characters)'
      
      @profile.name = '123456789012345678901234567890'
      @profile.should.be.valid
    end
    
    specify "validates time zone" do
      @profile.time_zone = 'Central Time (US & Canada)'
      @profile.should.save

      @profile.time_zone = 'Not a real time zone'
      @profile.should.not.save
      @profile.errors.on(:time_zone).should.equal 'is not included in the list'
    end
    
    specify "allows blank time zone" do
      @profile.time_zone = nil
      @profile.should.save
      
      @profile.time_zone = ''
      @profile.should.save
    end
  end

  context "Automatic Device Updates" do
    specify "will update fields on linked devices when saved" do
      @profile.update_attributes(:alert_on_idle => true, :idle_threshold => 20)
      @device.reload
      @device.alert_on_idle.should.equal true
      @device.idle_threshold.should.equal 20

      @profile.update_attributes(:alert_on_idle => false, :idle_threshold => 5)
      @device.reload
      @device.alert_on_idle.should.equal false
      @device.idle_threshold.should.equal 5
    end

    specify "will NOT update nil fields on linked devices" do
      @device.update_attributes(:alert_on_speed => false, :speed_threshold => 55)
      @profile.update_attributes(:alert_on_speed => nil, :speed_threshold => 75)
      @device.reload
      @device.alert_on_speed.should.equal false
      @device.speed_threshold.should.equal 55
    end

    specify "will NOT update time zone if nil or blank" do
      @device.update_attributes(:time_zone => 'Eastern Time (US & Canada)')
      @profile.update_attributes(:time_zone => nil)
      @device.reload.time_zone.should.equal 'Eastern Time (US & Canada)'

      @profile.update_attributes(:time_zone => '')
      @device.reload.time_zone.should.equal 'Eastern Time (US & Canada)'

      @profile.update_attributes(:time_zone => 'Central Time (US & Canada)')
      @device.reload.time_zone.should.equal 'Central Time (US & Canada)'
    end

    specify "prevents accidental updates of devices on other accounts" do
      # Yeah, this should never happen, but better safe than sorry
      device = devices(:aaron_device)
      device.update_attributes(:alert_on_speed => true, :speed_threshold => 55)

      # Intentionally assign an illegal profile id
      Device.update_all({:device_profile_id => @profile.id}, {:id => device.id})
      @profile.update_attributes(:alert_on_speed => false, :speed_threshold => 70)

      device.reload
      device.alert_on_speed.should.equal true
      device.speed_threshold.should.equal 55 
    end
  end
  
  specify "protects appropriate attributes" do
    profile = DeviceProfile.new(:account_id => 7, :name => 'test')
    profile.account_id.should.be.nil
    profile.name.should.equal('test')
    
    profile = DeviceProfile.new(:account => @account, :name => 'test')
    profile.account_id.should.equal(@account.id)
    profile.name.should.equal('test')
  end
end
