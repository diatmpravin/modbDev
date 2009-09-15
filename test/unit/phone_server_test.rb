require 'test_helper'
require File.join(RAILS_ROOT, 'lib', 'phone_server')

describe "Phone Server", ActiveSupport::TestCase do
  setup do
    # Create a "brain dead" version of an Event Machine Connection
    @connection = Object.new.extend(PhoneServer)
    @connection.post_init
  end
  
  context "Accepting incoming messages" do
    specify "processes an incoming message" do
      EventMachine.expects(:defer)
      
      @connection.receive_data('{"json":"i am in a json string"}'+"\n")
    end
    
    specify "ignores non-json messages" do
      EventMachine.expects(:defer).never
      
      @connection.receive_data('cleveland')
      @connection.receive_data('-34.080,80')
    end
    
    specify "processes messages broken into chunks" do
      EventMachine.expects(:defer).never
      @connection.receive_data('{"this is the start":"of json", ')
      
      EventMachine.expects(:defer).once
      @connection.receive_data('"and even more":"json"}' + "\n" + '{"start another":')
      
      EventMachine.expects(:defer).once
      @connection.receive_data('"last gasp"}' + "\n")
    end
  end
  
  context "Handling messages from devices" do
    specify "forwards to dispatch controllers" do
      Dispatch::Controller.expects(:dispatch).with('{json string}').returns('{json response}' + "\n")
      
      @connection.handle_request('{json string}').should.equal '{json response}'  + "\n"
    end
  end
  
  context "Starting phone server" do
    specify "works" do
      EventMachine.expects(:run)
      PhoneServer.run
    end
  end
  
  specify "knows the server host and port" do
    PhoneServer.servers.values.first[:host].should.equal 'testing'
    PhoneServer.servers.values.first[:port].should.equal 3000
  end
end
