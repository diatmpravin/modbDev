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
      @profile.should.respond_to(:devices)
      @device.update_attributes(:device_profile => @profile)
      assert @profile.reload.devices.include?(@device)
    end
  end
end
