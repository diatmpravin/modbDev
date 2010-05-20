require 'test_helper'
require File.join(RAILS_ROOT, 'lib', 'device_server')

describe "Device Server", ActiveSupport::TestCase do
  
  context "Handling reports from devices" do
    setup do
      @device = devices(:quentin_device)
    end
    
    specify "works" do
      Point.should.differ(:count).by(1) do
        DeviceServer::PointProcessor.new().process_point(
          '123456789012345,4001,2013/03/13,13:13:13,42.78894,-86.10680,172.8,0,0,0,0,0.0,10,1.6,17'
        )
      end
      
      point = @device.points.last
      point.occurred_at.should.equal Time.parse('2013/03/13 13:13:13 UTC')
    end

    specify "sends mail on exception" do
      Mailer.deliveries.clear
      Redis::Client.any_instance.expects(:set).raises "exception" 
      Redis::Client.any_instance.expects(:delete).returns true 
      DeviceServer::PointProcessor.new().process('123456789012345')
      Mailer.deliveries.length.should.be 1
    end
  end
  
  context "Starting device server" do
    specify "works" do
      EventMachine.expects(:run)
      DeviceServer.run
    end

    xspecify "NEED TO ADD TESTS FOR NEW DEVICE SERVER BEHAVIOR AND FIX OLD TESTS THAT DEPEND ON KLUDGE IN POINT UPDATE_PRECALC" do
    end
  end
end
