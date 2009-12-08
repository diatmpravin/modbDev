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
    
    xspecify "allows blank time zone" do
      
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
