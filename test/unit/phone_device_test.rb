require 'test_helper'

describe "Phone Device", ActiveSupport::TestCase do
  setup do
    @phone = phones(:quentin_phone)
    @device = devices(:quentin_device)
  end
  
  context "Associations" do
    specify "belongs to a phone" do
      PhoneDevice.new.should.respond_to(:phone)
      phone_devices(:quentin_pd).phone.should.equal @phone
    end
    
    specify "belongs to a device" do
      PhoneDevice.new.should.respond_to(:device)
      phone_devices(:quentin_pd).device.should.equal @device
    end
  end

  specify "protects appropriate attributes" do
    pd = PhoneDevice.new(:phone_id => @phone.id, :device_id => @device.id)
    pd.phone_id.should.be.nil
    pd.device_id.should.be.nil
    
    pd = PhoneDevice.new(:phone => @phone, :device => @device)
    pd.phone_id.should.equal @phone.id
    pd.device_id.should.equal @device.id
  end
end
