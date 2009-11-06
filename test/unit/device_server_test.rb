require 'test_helper'
require File.join(RAILS_ROOT, 'lib', 'device_server')

describe "Device Server", ActiveSupport::TestCase do
  setup do
    # Create a "brain dead" version of an Event Machine Connection
    @connection = Object.new.extend(DeviceServer)
    @connection.post_init
  end
  
  context "Accepting incoming messages" do
    specify "processes an incoming message" do
      EventMachine.expects(:defer)
      
      @connection.receive_data('$$8988216710503291272,4002,2009/02/17,17:06:59,42.78894,-86.10680,172.8,0,0,0,0,0.0,10,1.6,17##')
    end
    
    specify "ignores invalid messages" do
      EventMachine.expects(:defer).never
      
      @connection.receive_data('cleveland')
      @connection.receive_data('-34.80,80')
    end
    
    specify "processes messages broken into chunks" do
      EventMachine.expects(:defer).never
      @connection.receive_data('$$8988216710503291272,4002,2009/02/17,17:06:59,42.78894,-86.10680,')
      
      EventMachine.expects(:defer).once
      @connection.receive_data('172.8,0,0,0,0,0.0,10,1.6,17##$$8988216710503291272,4002,2009/02/17,')
      
      EventMachine.expects(:defer).once
      @connection.receive_data('17:06:59,42.78894,-86.10680,172.8,0,0,0,0,0.0,10,1.6,17##')
    end
  end
  
  context "Handling reports from devices" do
    setup do
      @device = devices(:quentin_device)
    end
    
    specify "works" do
      Point.should.differ(:count).by(1) do
        DeviceServer::ReportHandler.new(
          '$$123456789012345,4001,2013/03/13,13:13:13,42.78894,-86.10680,172.8,0,0,0,0,0.0,10,1.6,17##'
        ).call
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
  
  specify "knows the server host and port" do
    DeviceServer.servers.values.first[:host].should.equal 'testing'
    DeviceServer.servers.values.first[:port].should.equal 3000
    
    DeviceServer.servers.values.second[:host].should.equal 'testing'
    DeviceServer.servers.values.second[:port].should.equal 3001
    DeviceServer.servers.values.second[:type].should.equal 'udp'
  end
end
