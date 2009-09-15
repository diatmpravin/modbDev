require 'test_helper'

module DispatchTestHelper
  attr_accessor :request, :response
  
  def dispatch(hash)
    @request = ActiveSupport::JSON.encode(hash)
    
    r = Dispatch::Controller.dispatch(@request)
    r = r.split("\n")
    
    @response = ActiveSupport::JSON.decode(r[0])
    @response['binary'] = r[1] if r[1]
  end
  module_function :dispatch
  
  def dispatch_with(phone, hash)
    hash[:phone] ||= phone.activation_code
    hash[:moshi_key] ||= phone.moshi_key
    
    dispatch(hash)
  end
  module_function :dispatch_with
end

describe "Dispatch :: Phone Controller", ActionController::TestCase do
  context "Creating a phone" do
    include DispatchTestHelper
    
    specify "works" do
      Phone.expects(:create).returns(mock(:activation_code => 'YUP'))
    
      dispatch({'action' => 'create'})
      response.should.equal({'code' => 0, 'phone' => 'YUP'})
    end
  end
  
  context "Activating a phone" do
    include DispatchTestHelper
    setup do
      @phone = Phone.create
    end
    
    specify "works" do
      @phone.activate(accounts(:quentin))
      dispatch({'action' => 'activate', 'phone' => @phone.activation_code})
      response['code'].should.equal 0
      response['moshi_key'].should.equal @phone.reload.moshi_key
    end

    specify "errors out if failed subscription" do
      a = accounts(:quentin)
      a.subscription.update_attribute(:status, "cancelled")
      @phone.activate(a) 

      dispatch({'action' => 'activate', 'phone' => @phone.activation_code})
      response['code'].should.equal Dispatch::Errors::BAD_SUBSCRIPTION
    end
    
    specify "errors out if phone does not exist" do
      dispatch({'action' => 'activate', 'phone' => 'birds'})
      response['code'].should.equal Dispatch::Errors::INVALID_PHONE
    end
    
    specify "errors out if phone is not active" do
      dispatch({'action' => 'activate', 'phone' => @phone.activation_code})
      response['code'].should.equal Dispatch::Errors::INACTIVE_PHONE
    end
  end
  
  context "Activating by login" do
    include DispatchTestHelper
    setup do
      @phone = Phone.create
      @account = accounts(:quentin)
    end
    
    specify "works" do
      dispatch({'action' => 'activate_by_login',
        'phone' => @phone.activation_code,
        'username' => 'quentin',
        'password' => 'test'
      })
      
      response['code'].should.equal 0
      response['moshi_key'].should.equal @phone.reload.moshi_key
    end
    
    specify "errors out if phone does not exist" do
      dispatch({'action' => 'activate_by_login',
        'phone' => 'birds',
        'username' => 'quentin',
        'password' => 'test'
      })
      
      response['code'].should.equal Dispatch::Errors::INVALID_PHONE
    end
    
    specify "errors out if login is invalid" do
      dispatch({'action' => 'activate_by_login',
        'phone' => @phone.activation_code,
        'username' => 'quentin',
        'password' => 'not test'
      })
      
      response['code'].should.equal Dispatch::Errors::INVALID_LOGIN
    end
    
    specify "errors if there are too many phones" do
      Phone.expects(:count).returns(21)
      
      dispatch({'action' => 'activate_by_login',
        'phone' => @phone.activation_code,
        'username' => 'quentin',
        'password' => 'test'
      })
      
      response['code'].should.equal Dispatch::Errors::TOO_MANY_PHONES
    end
  end
  
  context "Starting a session" do
    include DispatchTestHelper
    setup do
      @phone = phones(:quentin_phone)
      @device = devices(:quentin_device)
      @geofence = geofences(:quentin_geofence)
    end
    
    specify "works" do
      dispatch_with(@phone, {'action' => 'session'})
      
      response['devices'].length.should.be 1
      response['devices'][0]['id'].should.equal @device.id
      response['geofences'].length.should.be 1
      response['geofences'][0]['id'].should.equal @geofence.id
    end
  end
  
  context "Getting trips list" do
    include DispatchTestHelper
    setup do
      @device = devices(:quentin_device)
      @phone = phones(:quentin_phone)
    end
    
    specify "works" do
      trip = trips(:quentin_trip)
      
      dispatch_with(@phone, {
        'action' => 'get_trips',
        'device_id' => @device.id,
        'start_date' => '20090201',
        'end_date' => '20090208'
      })
      
      response['code'].should.equal 0
      response['trips'].length.should.equal 1
      response['trips'][0]['id'].should.equal trip.id
    end

    specify "requires a valid subscription" do
      subscriptions(:quentin).update_attribute(:status, "cancelled")
      dispatch_with(@phone, {
        'action' => 'get_trips',
        'device_id' => @device.id,
        'start_date' => '20090201',
        'end_date' => '20090208'
      })
      
      response['code'].should.equal 8
    end
  
    specify "errors out if device don't belong to phone" do
      dispatch_with(@phone, {
        'action' => 'get_trips',
        'device_id' => devices(:aaron_device).id,
        'start_date' => '20090201',
        'end_date' => '20090208'
      })
    
      response['code'].should.equal 999
    end
    
    specify "includes trips that start before the date range" do
      good = trip_helper(Time.parse('01/15/2008'), Time.parse('02/01/2008 00:01:00'))
      bad = trip_helper(Time.parse('01/15/2008'), Time.parse('01/31/2008 23:59:00'))
      
      dispatch_with(@phone, {
        'action' => 'get_trips',
        'device_id' => @device.id,
        'start_date' => '20080201',
        'end_date' => '20080208'
      })
      
      response['code'].should.equal 0
      response['trips'].length.should.equal 1
      response['trips'][0]['id'].should.equal good.id
    end
    
    specify "includes trips that finish after the date range" do
      good = trip_helper(Time.parse('02/08/2008 23:59:00'), Time.parse('02/15/2008'))
      bad = trip_helper(Time.parse('02/09/2008 00:01:00'), Time.parse('02/15/2008'))
      
      dispatch_with(@phone, {
        'action' => 'get_trips',
        'device_id' => @device.id,
        'start_date' => '20080201',
        'end_date' => '20080208'
      })
    
      response['code'].should.equal 0
      response['trips'].length.should.equal 1
      response['trips'][0]['id'].should.equal good.id
    end
    
    specify "will accept a device_ids array" do
      trip = trips(:quentin_trip)
      
      dispatch_with(@phone, {
        'action' => 'get_trips',
        'device_ids' => [@device.id],
        'start_date' => '20090201',
        'end_date' => '20090208'
      })
      
      response['code'].should.equal 0
      response['trips'].length.should.equal 1
      response['trips'][0]['id'].should.equal trip.id
    end
    
    specify "will return trips for all if no devices are sent" do
      trip = trips(:quentin_trip)
      
      dispatch_with(@phone, {
        'action' => 'get_trips',
        'start_date' => '20090201',
        'end_date' => '20090208'
      })
      
      response['code'].should.equal 0
      response['trips'].length.should.equal 1
      response['trips'][0]['id'].should.equal trip.id
    end
    
    def trip_helper(start_time, end_time)
      trip = @device.trips.create
      leg = trip.legs.create
      leg.points.create(:occurred_at => start_time, :device => @device,
        :miles => 7)
      leg.points.create(:occurred_at => end_time, :device => @device,
        :miles => 14)
      trip
    end
  end
  
  context "Getting a multi-vehicle map" do
    include DispatchTestHelper
    setup do
      @phone = phones(:quentin_phone)
    end
    
    specify "works for a new map request" do
      # creates a session
      MapQuest.expects(:call).with {|s, xml| xml =~ /<CreateSession>/}.returns(
        '<CreateSessionResponse><SessionID>fraggle</SessionID>
         <MapState><Center></Center></MapState></CreateSessionResponse>')
      
      # calls best fit
      MapQuest.expects(:call).with {|s, xml| xml =~ /<UpdateSession>/}.returns(
        '<UpdateSessionResponse><MapState><Center></Center>
         </MapState></UpdateSessionResponse>').times(2)
      
      # calls pixels_for
      MapQuest.expects(:call).with {|s, xml| xml =~ /<LLToPix>/}.returns(
        '<LLToPixResponse><PointCollection><X>7</X><Y>7</Y></PointCollection>
         </LLToPixResponse>')
      
      dispatch_with(@phone, {
        'action' => 'get_map',
        'dimensions' => {
          'width' => 320,
          'height' => 240
        }
      })
      
      response['code'].should.equal 0
      response['center'].should.equal({'x' => 0, 'y' => 0})
      response['points'][0]['device_id'].should.equal devices(:quentin_device).id
    end
    
    specify "requires a valid subscription" do
      subscriptions(:quentin).update_attribute(:status, "cancelled")
      dispatch_with(@phone, {
        'action' => 'get_map',
        'dimensions' => {
          'width' => 320,
          'height' => 240
        }
      })
      
      response['code'].should.equal 8
    end

    specify "works for an updated map request" do
      # calls coordinates_for
      MapQuest.expects(:call).with {|s, xml| xml =~ /<PixToLL>/}.returns(
        '<PixToLLResponse><LatLngCollection><Lat>86000000</Lat><Lng>40000000</Lng></LatLngCollection></PixToLLResponse>')
      
      # calls zoom_to_level
      MapQuest.expects(:call).with {|s, xml| xml =~ /<UpdateSession>/}.returns(
        '<UpdateSessionResponse><MapState><Center></Center>
         </MapState></UpdateSessionResponse>')
      
      # calls pixels_for twice
      MapQuest.expects(:call).with {|s, xml| xml =~ /<LLToPix>/}.returns(
        '<LLToPixResponse><PointCollection><X>121</X><Y>107</Y></PointCollection>
         </LLToPixResponse>').times(2)
      
      dispatch_with(@phone, {
        'action' => 'get_map',
        'session_id' => 'fraggle',
        'map_state' => {
        },
        'zoom_level' => 10,
        'x' => 100,
        'y' => 100,
        'dimensions' => {
          'width' => 320,
          'height' => 240
        }
      })
      
      response['code'].should.equal 0
      response['center'].should.equal({'x' => 121 - 128, 'y' => 107 - 128})
      response['points'][0]['device_id'].should.equal devices(:quentin_device).id
    end
    
    specify "can call with a device_id to get a specific vehicle" do
      # creates a session
      MapQuest.expects(:call).with {|s, xml| xml =~ /<CreateSession>/}.returns(
        '<CreateSessionResponse><SessionID>fraggle</SessionID>
         <MapState><Center></Center></MapState></CreateSessionResponse>')
      
      # calls best fit
      MapQuest.expects(:call).with {|s, xml| xml =~ /<UpdateSession>/}.returns(
        '<UpdateSessionResponse><MapState><Center></Center>
         </MapState></UpdateSessionResponse>').times(2)
      
      # calls pixels_for
      MapQuest.expects(:call).with {|s, xml| xml =~ /<LLToPix>/}.returns(
        '<LLToPixResponse><PointCollection><X>7</X><Y>7</Y></PointCollection>
         </LLToPixResponse>')
      
      dispatch_with(@phone, {
        'action' => 'get_map',
        'device_id' => devices(:quentin_device).id,
        'dimensions' => {
          'width' => 320,
          'height' => 240
        }
      })
      
      response['code'].should.equal 0
      response['center'].should.equal({'x' => 0, 'y' => 0})
      response['points'][0]['device_id'].should.equal devices(:quentin_device).id
    end
    
    specify "can call with device_ids to get multiple vehicles" do
      # creates a session
      MapQuest.expects(:call).with {|s, xml| xml =~ /<CreateSession>/}.returns(
        '<CreateSessionResponse><SessionID>fraggle</SessionID>
         <MapState><Center></Center></MapState></CreateSessionResponse>')
      
      # calls best fit
      MapQuest.expects(:call).with {|s, xml| xml =~ /<UpdateSession>/}.returns(
        '<UpdateSessionResponse><MapState><Center></Center>
         </MapState></UpdateSessionResponse>').times(2)
      
      # calls pixels_for
      MapQuest.expects(:call).with {|s, xml| xml =~ /<LLToPix>/}.returns(
        '<LLToPixResponse><PointCollection><X>7</X><Y>7</Y></PointCollection>
         </LLToPixResponse>')
      
      dispatch_with(@phone, {
        'action' => 'get_map',
        'device_ids' => [devices(:quentin_device).id],
        'dimensions' => {
          'width' => 320,
          'height' => 240
        }
      })
      
      response['code'].should.equal 0
      response['center'].should.equal({'x' => 0, 'y' => 0})
      response['points'][0]['device_id'].should.equal devices(:quentin_device).id
    end
    
    specify "returns an error if there is no data available" do
      Point.delete_all
      
      dispatch_with(@phone, {
        'action' => 'get_map',
        'device_id' => devices(:quentin_device).id,
        'dimensions' => {
          'width' => 320,
          'height' => 240
        }
      })
      
      response['code'].should.equal Dispatch::Errors::NO_MAP_DATA
    end
  end
  
  context "Getting a trip map" do
    include DispatchTestHelper
    setup do
      @phone = phones(:quentin_phone)
      @trip = trips(:quentin_trip)
    end
    
    specify "works for a new map request" do
      # creates a session
      MapQuest.expects(:call).with {|s, xml| xml =~ /<CreateSession>/}.returns(
        '<CreateSessionResponse><SessionID>fraggle</SessionID>
         <MapState><Center></Center></MapState></CreateSessionResponse>')
      
      # calls best fit
      MapQuest.expects(:call).with {|s, xml| xml =~ /<UpdateSession>/}.returns(
        '<UpdateSessionResponse><MapState><Center></Center>
         </MapState></UpdateSessionResponse>').times(2)
      
      # calls pixels_for
      MapQuest.expects(:call).with {|s, xml| xml =~ /<LLToPix>/}.returns(
        '<LLToPixResponse><PointCollection><X>7</X><Y>7</Y></PointCollection>
         </LLToPixResponse>')
      
      dispatch_with(@phone, {
        'action' => 'get_trip_map',
        'device_id' => @trip.device_id,
        'trip_id' => @trip.id,
        'dimensions' => {
          'width' => 320,
          'height' => 240
        }
      })
      
      response['code'].should.equal 0
      response['center'].should.equal({'x' => 0, 'y' => 0})
      response['points'][0]['speed'].should.equal @trip.points.first.speed
    end
    
    specify "requires a valid subscription" do
      subscriptions(:quentin).update_attribute(:status, "cancelled")
      dispatch_with(@phone, {
        'action' => 'get_trip_map',
        'device_id' => @trip.device_id,
        'trip_id' => @trip.id,
        'dimensions' => {
          'width' => 320,
          'height' => 240
        }
      })
      
      response['code'].should.equal 8
    end
    
    specify "works for an updated map request" do
      # calls coordinates_for
      MapQuest.expects(:call).with {|s, xml| xml =~ /<PixToLL>/}.returns(
        '<PixToLLResponse><LatLngCollection><Lat>86000000</Lat><Lng>40000000</Lng></LatLngCollection></PixToLLResponse>')
      
      # calls zoom_to_level
      MapQuest.expects(:call).with {|s, xml| xml =~ /<UpdateSession>/}.returns(
        '<UpdateSessionResponse><MapState><Center></Center>
         </MapState></UpdateSessionResponse>')
      
      # calls pixels_for twice
      MapQuest.expects(:call).with {|s, xml| xml =~ /<LLToPix>/}.returns(
        '<LLToPixResponse><PointCollection><X>121</X><Y>107</Y></PointCollection>
         </LLToPixResponse>').times(2)
      
      dispatch_with(@phone, {
        'action' => 'get_trip_map',
        'trip_id' => @trip.id,
        'device_id' => @trip.device_id,
        'session_id' => 'fraggle',
        'map_state' => {
        },
        'zoom_level' => 10,
        'x' => 100,
        'y' => 100,
        'dimensions' => {
          'width' => 320,
          'height' => 240
        }
      })
      
      response['code'].should.equal 0
      response['center'].should.equal({'x' => 121 - 128, 'y' => 107 - 128})
      response['points'][0]['speed'].should.equal @trip.points.first.speed
    end
  end
  
  # Uses "tiles" from /test/fixtures/tmp/cache
  context "Getting map tiles" do
    include DispatchTestHelper
    setup do
      @phone = phones(:quentin_phone)
    end
    
    specify "works" do
      dispatch_with(@phone, {
        'action' => 'get_tile',
        'col' => -2,
        'row' => -2,
        'session_id' => 'free-beer'
      })
      
      response.should.equal({
        'code' => 0,
        'tiles' => [{'col' => -2, 'row' => -2, 'length' => 1}],
        'binary' => 'a'
      })
    end

    specify "requires a valid subscription" do
      subscriptions(:quentin).update_attribute(:status, "cancelled")
      dispatch_with(@phone, {
        'action' => 'get_tile',
        'col' => -2,
        'row' => -2,
        'session_id' => 'free-beer'
      })
      
      response['code'].should.equal 8
    end
    
  end
  
  # Uses "tiles" from /test/fixtures/tmp/cache
  context "Getting multiple map tiles" do
    include DispatchTestHelper
    setup do
      @phone = phones(:quentin_phone)
    end
    
    specify "works" do
      dispatch_with(@phone, {
        'action' => 'get_tiles',
        'tiles' => [
          {'col' => -2, 'row' => -2}
        ],
        'session_id' => 'free-beer'
      })
      
      response.should.equal({
        'code' => 0,
        'tiles' => [{'col' => -2, 'row' => -2, 'length' => 1}],
        'binary' => 'a'
      })
    end

    specify "requires a valid subscription" do
      subscriptions(:quentin).update_attribute(:status, "cancelled")
      dispatch_with(@phone, {
        'action' => 'get_tiles',
        'tiles' => [
          {'col' => -2, 'row' => -2}
        ],
        'session_id' => 'free-beer'
      })
      
      response['code'].should.equal 8
    end
    
  end
  
  context "Toggling geofences" do
    include DispatchTestHelper
    setup do
      @phone = phones(:quentin_phone)
      @device = devices(:quentin_device)
      @geofence = geofences(:quentin_geofence)
    end
    
    specify "unlinks correctly" do
      @device.geofences.should.include @geofence
      
      dispatch_with(@phone, {
        'action' => 'associate_geofence',
        'device_id' => @device.id,
        'geofence_id' => @geofence.id,
        'associated' => false
      })
      
      response.should.equal({'code' => 0, 'geofence_ids' => []})
      @device.reload.geofences.should.not.include @geofence
      
      dispatch_with(@phone, {
        'action' => 'associate_geofence',
        'device_id' => @device.id,
        'geofence_id' => @geofence.id,
        'associated' => false
      })
      
      response.should.equal({'code' => 0, 'geofence_ids' => []})
      @device.reload.geofences.should.not.include @geofence
    end

    specify "requires a valid subscription" do
      subscriptions(:quentin).update_attribute(:status, "cancelled")
      dispatch_with(@phone, {
        'action' => 'associate_geofence',
        'device_id' => @device.id,
        'geofence_id' => @geofence.id,
        'associated' => false
      })
      
      response['code'].should.equal 8
    end
    
    specify "links correctly" do
      @device.geofences.clear
      @device.geofences.should.not.include @geofence
      
      dispatch_with(@phone, {
        'action' => 'associate_geofence',
        'device_id' => @device.id,
        'geofence_id' => @geofence.id,
        'associated' => true
      })
      
      response.should.equal({'code' => 0, 'geofence_ids' => [@geofence.id]})
      @device.reload.geofences.should.include @geofence
      
      dispatch_with(@phone, {
        'action' => 'associate_geofence',
        'device_id' => @device.id,
        'geofence_id' => @geofence.id,
        'associated' => true
      })
      
      response.should.equal({'code' => 0, 'geofence_ids' => [@geofence.id]})
      @device.reload.geofences.should.include @geofence
    end
  end
end
