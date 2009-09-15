require 'test_helper'

describe "Device Geofence", ActiveSupport::TestCase do
  setup do
    @device = devices(:quentin_device)
    @geofence = geofences(:quentin_geofence)
  end
  
  context "Associations" do
    specify "belongs to a device" do
      DeviceGeofence.new.should.respond_to(:device)
      device_geofences(:quentin_df).device.should.equal @device
    end
    
    specify "belongs to a geofence" do
      DeviceGeofence.new.should.respond_to(:geofence)
      device_geofences(:quentin_df).geofence.should.equal @geofence
    end
  end
  
  specify "protects appropriate attributes" do
    df = DeviceGeofence.new(:device_id => @device.id, :geofence_id => @geofence.id)
    df.device_id.should.be.nil
    df.geofence_id.should.be.nil
    
    df = DeviceGeofence.new(:device => @device, :geofence => @geofence)
    df.device_id.should.equal @device.id
    df.geofence_id.should.equal @geofence.id
  end
end
