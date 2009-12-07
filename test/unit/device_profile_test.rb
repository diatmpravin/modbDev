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
  
  specify "protects appropriate attributes" do
    profile = DeviceProfile.new(:account_id => 7, :name => 'test')
    profile.account_id.should.be.nil
    profile.name.should.equal('test')
    
    profile = DeviceProfile.new(:account => @account, :name => 'test')
    profile.account_id.should.equal(@account.id)
    profile.name.should.equal('test')
  end
end
