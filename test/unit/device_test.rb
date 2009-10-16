require 'test_helper'

describe "Device", ActiveSupport::TestCase do
  setup do
    @account = accounts(:quentin)
    @phone = phones(:quentin_phone)
    @device = devices(:quentin_device)
  end
  
  context "Associations" do
    specify "belongs to an account" do
      @device.should.respond_to(:account)
      @device.account.should.equal @account
    end
    
    specify "has many points" do
      @device.should.respond_to(:points)
    end
    
    specify "has many trips" do
      @device.should.respond_to(:trips)
    end
    
    specify "has many phones" do
      @device.should.respond_to(:phones)
      @device.phones.should.include(@phone)
    end
    
    specify "has many geofences" do
      @device.should.respond_to(:geofences)
      @device.geofences.should.include(geofences(:quentin_geofence))
    end
    
    specify "has many alert recipients" do
      @device.should.respond_to(:alert_recipients)
      @device.alert_recipients.should.include(alert_recipients(:quentin_recipient))
    end
    
    specify "has many events" do
      @device.should.respond_to(:events)
      @device.events.should.include(events(:quentin_event))
    end
  end
  
  specify "protects appropriate attributes" do
    device = Device.new(:account_id => 7, :name => "test")
    device.account_id.should.be.nil
    device.name.should.equal("test")
    
    device = Device.new(:account => accounts(:quentin), :name => "test")
    device.account_id.should.equal(accounts(:quentin).id)
    device.name.should.equal("test")
  end
  
  context "Validations" do
    specify "limits name to 30 chars" do
      @device.name = "I'm exactly 30 characters long"
      @device.should.be.valid
      
      @device.name = "I'm a name that's 31 characters"
      @device.should.not.be.valid
      @device.errors.on(:name).should.equal("is too long (maximum is 30 characters)")
    end
    
    specify "enforces number of records" do
      Device.delete_all
      20.times do |i|
        d = @account.devices.new(:name => 'Test')
        d.tracker = Tracker.create(:imei_number => "0000000000000#{'%02d'%i}")
        d.should.save
      end
      d = @account.devices.new(:name => 'Test')
      d.tracker = Tracker.create(:imei_number => "000000000000021")
      d.should.not.be.valid
      d.errors.on(:base).should.equal 'Too many devices'
      
      # Make sure we can update
      d = Device.last
      d.name = 'New Name'
      d.should.save
    end
    
    specify "odometer is numeric" do
      @device.odometer = 'abc'
      @device.should.not.be.valid
      @device.errors.on(:odometer).should.equal('is not a number')
      
      @device.odometer = 12
      @device.should.be.valid
    end
  end
  
  context "Parsing device reports" do
    setup do
      @device.points.clear
      @device.trips.clear
      
      # Car starts out with ignition off
      @device.points.create(
        :event => 4002,
        :latitude => 33.64512,
        :longitude => -84.44697
      )
      @device.trips.create(:name => "One")
      
      @example_location = {
        :sim => '12345678901234567890',
        :event => '4001',
        :date => '2009/02/17',
        :time => '12:18:54',
        :latitude => '33.64512',
        :longitude => '-84.44697',
        :altitude => '312.1',
        :speed => '31',
        :accelerating => '0',
        :decelerating => '1',
        :rpm => '866',
        :heading => '218.0',
        :satellites => '9',
        :hdop => '1.6',
        :miles => '21',
        :mpg => '18.2',
        :battery => '13.1',
        :signal => '23',
        :gps => '1'
      }
      
      Mailer.deliveries.clear
    end
    
    specify "handles a location report" do
      Point.should.differ(:count).by(1) do
        @device.process(@example_location)
      end
      assert !points(:quentin_point).latitude.nil?
      Point.find(:last).device_id.should.equal @device.id
    end
    
    context "Trip handling" do
      specify "creates a new trip when car turns on" do
        Trip.should.differ(:count).by(1) do
          Leg.should.differ(:count).by(1) do
            @device.process(@example_location)
          end
        end
      
        Point.find(:last).leg.trip.device_id.should.equal @device.id
      end
      
      specify "continues an existing trip if car is still on" do
        @device.process(@example_location)
        point1 = Point.find(:last)
        
        Trip.should.differ(:count).by(0) do
          Leg.should.differ(:count).by(0) do
            @device.process(@example_location)
          end
        end
        point2 = Point.find(:last)
        
        point1.leg.should.equal point2.leg
        point1.leg.trip.should.equal point2.leg.trip
      end
      
      specify "continues an existing trip over non-trip markers" do
        @device.process(@example_location)
        point1 = Point.find(:last)
        
        @example_location[:event] = '4006'
        @device.process(@example_location)
        point2 = Point.find(:last)
        
        @example_location[:event] = '4001'
        Trip.should.differ(:count).by(0) do
          Leg.should.differ(:count).by(0) do
            @device.process(@example_location)
          end
        end
        point3 = Point.find(:last)
        
        point3.leg.should.equal point1.leg
        point2.leg.should.equal point1.leg
        point3.leg.trip.should.equal point1.leg.trip
      end
      
      specify "ignores non-trip markers when not in a trip" do
        @example_location[:event] = '4006'
        
        Trip.should.differ(:count).by(0) do
          Leg.should.differ(:count).by(0) do
            @device.process(@example_location)
          end
        end
        point = Point.find(:last)
        
        point.leg.should.be.nil
      end
      
      specify "creates a new trip if the last point is too old" do
        @device.process(@example_location)
        @example_location[:time] = '20:18:54'
        
        Trip.should.differ(:count).by(1) do
          Leg.should.differ(:count).by(1) do
            @device.reload.process(@example_location)
          end
        end
        
        Point.find(:last).leg.trip.device_id.should.equal @device.id
      end
      
      specify "will not build trips if car is off" do
        @example_location[:event] = '4002'
        
        Trip.should.differ(:count).by(0) do
          Leg.should.differ(:count).by(0) do
            @device.process(@example_location)
          end
        end
        point = Point.find(:last)
        
        point.device_id.should.equal @device.id
        point.leg.should.be.nil
      end
      
      specify "will update odometer" do
        @device.update_attribute(:odometer, 37000)
        
        @example_location[:miles] = 30
        @example_location[:time] = '20:18:54'
        @device.process(@example_location)
        
        @device.reload.odometer.should.equal 37000
        
        @example_location[:miles] = 36
        @example_location[:time] = '20:22:54'
        @device.process(@example_location)
        
        @device.reload.odometer.should.equal 37006
      end
    end
    
    context "Geofence checking" do
      setup do
        @geofence = geofences(:quentin_geofence)
      end
      
      specify "no alerts sent if no flags are set" do
        @geofence.update_attributes(:alert_on_entry => false, :alert_on_exit => false)
        Geofence.any_instance.expects(:contain? ).times(2).returns(true, false)
        
        @device.process(@example_location)
        Mailer.deliveries.length.should.be 0
      end
      
      specify "entry alert works" do
        @geofence.update_attributes(:alert_on_entry => true)
        Geofence.any_instance.expects(:contain? ).times(2).returns(true, false)
        
        @device.process(@example_location)
        Mailer.deliveries.length.should.be 1
        Mailer.deliveries.first.body.should =~ /Quentin's Device entered area Home/
      end
      
      specify "exit alert works" do
        @geofence.update_attributes(:alert_on_exit => true)
        Geofence.any_instance.expects(:contain? ).times(4).returns(true, true, false, true)
        
        @device.process(@example_location)
        Mailer.deliveries.length.should.be 1
        Mailer.deliveries.first.body.should =~ /Quentin's Device exited area Home/
      end
      
      specify "alerts are sent only once" do
        @geofence.update_attributes(:alert_on_entry => true)
        @geofence.update_attributes(:alert_on_exit => true)
        Geofence.any_instance.expects(:contain? ).at_least_once.returns(true)
        
        @device.process(@example_location)
        Mailer.deliveries.length.should.be 0
      end
    end
    
    context "Speed thresholds" do
      specify "creates events" do
        @device.update_attribute(:speed_threshold, 75)
        @example_location[:event] = '6002'
        @example_location[:speed] = '76'
        
        Event.should.differ(:count).by(1) do
          @device.process(@example_location)
        end
        Mailer.deliveries.length.should.be 0
      end
      
      specify "sends alerts" do
        @device.update_attribute(:speed_threshold, 75)
        @device.update_attribute(:alert_on_speed, true)
        @example_location[:event] = '6002'
        @example_location[:speed] = '76'
        
        @device.process(@example_location)
        Mailer.deliveries.length.should.be 1
        Mailer.deliveries.first.body.should =~ /Quentin's Device speed reached 76 mph \(exceeded limit of 75 mph\)/
      end
    end
    
    context "Rapid acceleration" do
      specify "creates events" do
        @example_location[:event] = DeviceReport::Event::ACCELERATING
        #@example_location[:accelerating] = '1'
        #@example_location[:decelerating] = '0'
        
        Event.should.differ(:count).by(1) do
          @device.process(@example_location)
        end
        Mailer.deliveries.length.should.be 0
      end
      
      specify "sends alerts" do
        @device.update_attribute(:alert_on_aggressive, true)
        @example_location[:event] = DeviceReport::Event::ACCELERATING
        #@example_location[:accelerating] = '1'
        #@example_location[:decelerating] = '0'
        
        @device.process(@example_location)
        Mailer.deliveries.length.should.be 1
        Mailer.deliveries.first.body.should =~ /Quentin's Device experienced rapid acceleration/
      end
    end
    
    context "Rapid deceleration" do
      specify "creates events" do
        @example_location[:event] = DeviceReport::Event::DECELERATING
        #@example_location[:accelerating] = '0'
        #@example_location[:decelerating] = '1'
        
        Event.should.differ(:count).by(1) do
          @device.process(@example_location)
        end
        Mailer.deliveries.length.should.be 0
      end
      
      specify "sends alerts" do
        @device.update_attribute(:alert_on_aggressive, true)
        @example_location[:event] = DeviceReport::Event::DECELERATING
        #@example_location[:accelerating] = '0'
        #@example_location[:decelerating] = '1'
        
        @device.process(@example_location)
        Mailer.deliveries.length.should.be 1
        Mailer.deliveries.first.body.should =~ /Quentin's Device experienced rapid deceleration/
      end
    end

    context "After Hours" do

      setup do
        @device.update_attributes(
          :alert_on_after_hours => true,
          :after_hours_start => 64800,  # 18:00
          :after_hours_end => 21600     # 06:00
        )
      end

      ##
      ## NOTE: All times merged into @example_location are given in 
      ##       GMT and the account we're working with is EST - 5
      ##

      specify "sets event and alert when trip crosses after-hour boundary" do
        # Point right before
        Event.should.differ(:count).by(0) do
          @device.process(@example_location.merge(:time => "22:55:00"))
        end

        # Point right after
        Event.should.differ(:count).by(1) do
          @device.process(@example_location.merge(:time => "23:00:10"))
        end

        Mailer.deliveries.length.should.be 1
        Mailer.deliveries.first.body.should =~ /Quentin's Device is running after hours/

        p = Point.find(:last)
        p.events.length.should.equal 1
        p.events[0].event_type.should.equal Event::AFTER_HOURS
      end

      specify "sets event and alert when new trip started during after-hours" do
        # Point right before
        Event.should.differ(:count).by(1) do
          @device.process(@example_location.merge(
            :time => "23:10:00", :event => '6011'))
        end

        Mailer.deliveries.length.should.be 1
        Mailer.deliveries.first.body.should =~ /Quentin's Device is running after hours/

        p = Point.find(:last)
        p.events.length.should.equal 1
        p.events[0].event_type.should.equal Event::AFTER_HOURS
      end

      specify "only sends one alert per trip leg" do
        # Start the trip
        Event.should.differ(:count).by(0) do
          @device.process(@example_location.merge(:time => "22:55:00"))
        end

        # Multiple points
        Event.should.differ(:count).by(5) do
          @device.process(@example_location.merge(:time => "23:00:10"))
          @device.process(@example_location.merge(:time => "23:30:10"))
          @device.process(@example_location.merge(:time => "00:10:10", :date => "2009/02/18"))
          @device.process(@example_location.merge(:time => "02:32:52", :date => "2009/02/18"))
          @device.process(@example_location.merge(:time => "03:30:30", :date => "2009/02/18"))
        end

        @device.process(@example_location.merge(:time => "03:33:30", :date => "2009/02/18", :event => '6012'))

        Mailer.deliveries.length.should.equal 1


        # New trip
        Trip.should.differ(:count).by(1) do
          Event.should.differ(:count).by(3) do
            @device.process(@example_location.merge(:time => "05:00:00", :date => "2009/02/18", :event => '6011'))
            @device.process(@example_location.merge(:time => "05:30:00", :date => "2009/02/18"))
            @device.process(@example_location.merge(:time => "06:30:00", :date => "2009/02/18"))
          end
        end

        @device.process(@example_location.merge(:time => "06:30:00", :date => "2009/02/18", :event => '6012'))
        
        Mailer.deliveries.length.should.equal 2

        # No longer after-hours
        Trip.should.differ(:count).by(1) do
          Event.should.differ(:count).by(0) do
            @device.process(@example_location.merge(:time => "11:01:00", :date => "2009/02/18", :event => '6011'))
            @device.process(@example_location.merge(:time => "11:20:00", :date => "2009/02/18"))
          end
        end

        # No more deliveries
        Mailer.deliveries.length.should.equal 2
      end

      specify "all points made during after-hours are flagged as such" do
        # Multiple points
        Event.should.differ(:count).by(5) do
          @device.process(@example_location.merge(:time => "23:00:10"))
          @device.process(@example_location.merge(:time => "23:30:10"))
          @device.process(@example_location.merge(:time => "00:10:10", :date => "2009/02/18"))
          @device.process(@example_location.merge(:time => "02:32:52", :date => "2009/02/18"))
          @device.process(@example_location.merge(:time => "03:30:30", :date => "2009/02/18"))
        end

        @device.trips.last.points.each do |point|
          assert point.events.exists?(:event_type => Event::AFTER_HOURS)
        end
      end

    end
    
    specify "will update extended information if available" do
      @example_location[:fw_version] = 'ABCD'
      @example_location[:obd_fw_version] = '0011'
      @example_location[:profile] = 'FacDflt'
      @example_location[:vin] = 'Z1ABCD'
      
      @device.process(@example_location)
      @device.fw_version.should.equal 'ABCD'
      @device.obd_fw_version.should.equal '0011'
      @device.profile.should.equal 'FacDflt'
      @device.reported_vin_number.should.equal 'Z1ABCD'
    end
  end
  
  specify "knows its last position" do
    @device.position.should.equal @device.points.last
    
    @device.points.delete_all
    @device.reload.position.should.be.nil
  end
  
  context "Time Zone" do
    specify "validates time zone" do
      @device.time_zone = 'Central Time (US & Canada)'
      @device.should.save
      
      @device.time_zone = 'Not a real time zone'
      @device.should.not.save
      @device.errors.on(:time_zone).should.equal 'is not included in the list'
    end
    
    specify "has a shortcut for its zone object" do
      @device.time_zone = 'Eastern Time (US & Canada)'
      @device.zone.name.should.equal 'Eastern Time (US & Canada)'
    end
  end
  
  specify "allows alert_recipient_ids=, but enforces account ownership" do
    @recipient = alert_recipients(:quentin_recipient)
    
    @device.update_attributes(:alert_recipient_ids => [])
    @device.alert_recipients.should.be.empty
    
    @device.update_attributes(:alert_recipient_ids => [@recipient.id])
    @device.alert_recipients.should.include(@recipient)
    
    should.raise(ActiveRecord::RecordNotFound) do
      bad = alert_recipients(:aaron_recipient)
      @device.update_attributes(:alert_recipient_ids => [@recipient.id, bad.id])
    end
  end
  
  specify "assigns any phones on the account automatically" do
    test_phone = Phone.new(:name => 'Delicious Phone')
    @account.phones << test_phone
    
    d = @account.devices.new(:name => 'Brand New')
    d.tracker = Tracker.create(:imei_number => '182340981750984')
    d.phones.should.be.empty
    
    d.should.save
    d.phones.should.equal @account.phones
    
    # Doesn't apply if you give it a specific phone list
    d = @account.devices.new(:name => 'specifying a Phone', :phones => [test_phone])
    d.tracker = Tracker.create(:imei_number => '987321000192873')
    d.phones.should.equal [test_phone]
    
    d.should.save
    d.phones.should.equal [test_phone]
  end
  
  specify "has getters and setters for TEXT after_hours time" do
    @device.after_hours_start_text = '12:00 am'
    @device.after_hours_start.should.equal 0
    
    @device.after_hours_end_text = '12:00pm'
    @device.after_hours_end.should.equal 43200
    
    @device.after_hours_start = 68460
    @device.after_hours_start_text.should.equal '07:01 pm'
    
    @device.after_hours_end = 60
    @device.after_hours_end_text.should.equal '12:01 am'
  end
end
