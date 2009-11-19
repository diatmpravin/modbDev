require 'test_helper'

describe "Device Tag", ActiveSupport::TestCase do
  setup do
    @device = devices(:quentin_device)
    @tag = tags(:quentin_tag)
    @dt = device_tags(:quentin_dt)
  end
  
  context "Associations" do
    specify "belongs to a device" do
      @dt.device.should.equal @device
    end
    
    specify "belongs to a tag" do
      @dt.tag.should.equal @tag
    end
  end
  
  specify "protects appropriate attributes" do
    dt = DeviceTag.new(:device_id => @device.id, :tag_id => @tag.id)
    dt.device_id.should.be.nil
    dt.tag_id.should.be.nil
    
    dt = DeviceTag.new(:device => @device, :tag => @tag)
    dt.device_id.should.equal @device.id
    dt.tag_id.should.equal @tag.id
  end
end
