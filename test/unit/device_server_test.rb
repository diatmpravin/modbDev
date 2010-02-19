require 'test_helper'
require File.join(RAILS_ROOT, 'lib', 'device_server')

describe "Device Server", ActiveSupport::TestCase do
  
  context "Handling reports from devices" do
    setup do
      @device = devices(:quentin_device)
    end
    
    specify "works" do
      Point.should.differ(:count).by(1) do
        DeviceServer::Worker.new().process_point(
          '123456789012345,4001,2013/03/13,13:13:13,42.78894,-86.10680,172.8,0,0,0,0,0.0,10,1.6,17'
        )
      end
      
      point = @device.points.last
      point.occurred_at.should.equal Time.parse('2013/03/13 13:13:13 UTC')
    end
  end
  
  context "Starting device server" do
    specify "works" do
      EventMachine.expects(:run)
      DeviceServer.run
    end
  end
end
