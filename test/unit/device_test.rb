require 'test_helper'

describe "Device", ActiveSupport::TestCase do
  setup do
    @account = accounts(:quentin)
    @device = devices(:quentin_device)
  end

  context "Associations" do
    specify "belongs to an account" do
      @device.should.respond_to(:account)
      @device.account.should.equal @account
    end

    specify "belongs to a profile" do
      @device.should.respond_to(:device_profile)
    end
    
    specify "has many points" do
      @device.should.respond_to(:points)
    end

    specify "has many trips" do
      @device.should.respond_to(:trips)
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
    
    specify "has many tags" do
      @device.should.respond_to(:tags)
      @device.tags.should.include(tags(:quentin_tag))
    end
  end

  context "Groups" do

    setup do
      @group = groups(:north)
      @group.devices << @device
      @device.reload
    end

    specify "belongs to many groups" do
      @device.groups.should.equal [groups(:north)]

      groups(:south).devices << @device
      @device.reload

      @device.groups.should.equal [groups(:north), groups(:south)]
    end

    specify "can get a list of group names" do
      groups(:south).devices << @device
      @device.reload

      @device.group_names.should.equal ["North", "South"]
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
    specify "name must be present" do
      @device.name = nil
      @device.should.not.be.valid
      @device.errors.on(:name).should.equal "can't be blank"
      
      @device.name = ''
      @device.should.not.be.valid
      @device.errors.on(:name).should.equal "can't be blank"
      
      @device.name = '1'
      @device.should.be.valid
    end
    
    specify "name must be less than 30 characters" do
      @device.name = '1234567890123456789012345678901'
      @device.should.not.be.valid
      @device.errors.on(:name).should.equal 'is too long (maximum is 30 characters)'
      
      @device.name = '123456789012345678901234567890'
      @device.should.be.valid
    end
    
    specify "odometer is numeric" do
      @device.odometer = 'abc'
      @device.should.not.be.valid
      @device.errors.on(:odometer).should.equal('is not a number')

      @device.odometer = 12
      @device.should.be.valid
    end

    specify "requires tracker to be visible by owned account" do
      tracker = Tracker.create(:imei_number => '999940981750984', :account => @account)

      tracker.should.not.be.new_record

      # can't put quentin tracker on aaron device
      device = Device.create(:account => accounts(:aaron), :name => "test")
      device.should.be.valid
      device.tracker = tracker
      device.should.not.be.valid
      device.errors.on(:imei_number).should.match('is not owned')

      # ok to put it on quentin device
      device.account = accounts(:quentin)
      device.should.be.valid      
    end

    specify "cannot assign a tracker that is already on another device" do
      device = Device.create(:account => accounts(:quentin), :name => "test")
      device.should.be.valid
      device.tracker = @device.tracker
      device.should.not.be.valid
      device.errors.on(:imei_number).should.match('is already assigned')
    end

  end

  context "Parsing device reports" do
    setup do
      @device.points.clear
      @device.trips.clear

      # Car starts out with ignition off
      @device.points.create(
        :occurred_at => Time.parse('2009/02/05 09:00:00 UTC'),
        :event => 4002,
        :latitude => 33.64512,
        :longitude => -84.44697
      )
      @device.trips.create(:name => "One")

      @example_location = {
        :sim => '12345678901234567890',
        :event => '4001',
        :date => '2009/02/05',
        :time => '09:18:54',
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

      specify "creeates a new trip anytime it receives IGNITION_ON" do
        @device.process(@example_location)
        @example_location[:time] = '20:18:54'
        @example_location[:event] = '6011'

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
     
      specify "will create a new leg on an existing trip if mileage rolls over" do
        @device.process(@example_location.merge(:event => '6011', :time => '14:00:00', :miles => '20'))
        point1 = Point.find(:last)
        @device.process(@example_location.merge(:event => '4001', :time => '14:02:00', :miles => '21'))
        point2 = Point.find(:last)
        @device.process(@example_location.merge(:event => '4001', :time => '14:05:00', :miles => '5'))
        point3 = Point.find(:last)
        
        point2.leg.should.equal point1.leg
        point3.leg.should.not.equal point2.leg
        point3.leg.trip.should.equal point2.leg.trip
      end

      specify "will create a new leg on an existing trip within the pitstop threshold" do
        @device.update_attributes(:detect_pitstops => true, :pitstop_threshold => 5)
        
        @device.process(@example_location.merge(:event => '6011', :time => '14:00:00'))
        point1 = Point.find(:last)
        @device.process(@example_location.merge(:event => '6012', :time => '14:15:00'))
        point2 = Point.find(:last)
        @device.process(@example_location.merge(:event => '6011', :time => '14:19:45'))
        point3 = Point.find(:last)
        
        point2.leg.should.equal point1.leg
        point3.leg.should.not.equal point2.leg
        point3.leg.trip.should.equal point2.leg.trip
      end
      
      specify "will not create a new leg on an existing trip outside the pitstop threshold" do
        @device.update_attributes(:detect_pitstops => true, :pitstop_threshold => 5)
        
        @device.process(@example_location.merge(:event => '6011', :time => '14:00:00'))
        point1 = Point.find(:last)
        @device.process(@example_location.merge(:event => '6012', :time => '14:15:00'))
        point2 = Point.find(:last)
        @device.process(@example_location.merge(:event => '6011', :time => '14:20:05'))
        point3 = Point.find(:last)
        
        point2.leg.should.equal point1.leg
        point3.leg.should.not.equal point2.leg
        point3.leg.trip.should.not.equal point2.leg.trip
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

    context "Landmark checking" do
      setup do
        @landmark = landmarks(:quentin)
      end

      specify "points outside the landmark do not get events" do
        @device.process(@example_location)
        @device.points.reload.last.events.should.be.empty
      end

      specify "points inside the landmark do get events" do
        # Sanity check
        @landmark.radius.should.equal 100
        @landmark.latitude.should.equal BigDecimal.new('40.22222')
        @landmark.longitude.should.equal BigDecimal.new('-86.33333')

        # Test
        @example_location[:latitude] = '40.223'
        @example_location[:longitude] = '-86.33333'

        @device.process(@example_location)
        point = @device.points.reload.last

        point.events.should.not.be.empty
        point.events.first.event_type.should.equal Event::AT_LANDMARK
      end
    end

    context "speed alerts" do
      setup do
        @device.points.clear
        @device.update_attribute(:speed_threshold, 50)
        @device.update_attribute(:alert_on_speed, true)
      end

      specify "creates events and sends alerts on breaking the threshold" do
        @example_location[:speed] = 51

        Event.should.differ(:count).by(1) do
          @device.process(@example_location)
        end
        Mailer.deliveries.length.should.be 1
      end

      specify "only create events if flagged to alert" do
        @example_location[:speed] = 51
        @device.update_attribute(:alert_on_speed, false)

        Event.should.differ(:count).by(0) do
          @device.process(@example_location)
        end
        Mailer.deliveries.length.should.be 0
      end

      specify "only send alerts on point that break the speed alert barrier" do
        # No alert, no event
        @example_location[:speed] = 45
        @example_location[:time] = '12:18:54'
        Event.should.differ(:count).by(0) { @device.process(@example_location) }

        # Alert!
        @example_location[:speed] = 51
        @example_location[:time] = '12:19:10'
        Event.should.differ(:count).by(1) { @device.process(@example_location) }

        # No alert
        @example_location[:speed] = 52
        @example_location[:time] = '12:19:30'
        Event.should.differ(:count).by(1) { @device.process(@example_location) }

        # No alert
        @example_location[:speed] = 48
        @example_location[:time] = '12:20:00'
        Event.should.differ(:count).by(0) { @device.process(@example_location) }

        # Alert again!
        @example_location[:speed] = 51
        @example_location[:time] = '12:20:20'
        Event.should.differ(:count).by(1) { @device.process(@example_location) }

        Mailer.deliveries.length.should.equal 2
      end
    end

    context "Idle" do
      specify "creates events" do
        occurred_at = Time.parse("#{@example_location[:date]} #{@example_location[:time]} UTC")
        @example_location[:speed] = 0

        Event.should.differ(:count).by(1) do
          for i in 1..9
            new_time = i.minutes.since(occurred_at)
            @device.process(@example_location)
            @example_location[:time] = "#{new_time.hour}:#{new_time.min}:#{new_time.sec}"
          end

          #@device.process(@example_location)
        end
        Mailer.deliveries.length.should.be 0
      end

      specify "sends alerts" do
        occurred_at = Time.parse("#{@example_location[:date]} #{@example_location[:time]} UTC")
        
        @device.update_attribute(:alert_on_idle, true)
        @example_location[:speed] = 0
        Event.should.differ(:count).by(1) do
          for i in 1..9
            new_time = i.minutes.since(occurred_at)
            @device.process(@example_location)
            @example_location[:time] = "#{new_time.hour}:#{new_time.min}:#{new_time.sec}"
          end
        end
        Mailer.deliveries.length.should.be 1
        Mailer.deliveries.first.body.should =~ /idle/  
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

    context "Device Not Reporting" do
      specify "creates events" do
        Event.should.differ(:count).by(1) do
          @device.process(@example_location.merge(:time => "12:05:00"))
        end
        p = Point.find(:last)
        p.events.length.should.equal 1
        p.events[0].event_type.should.equal Event::NOT_REPORTING
      end
    end

    context "After Hours" do
      setup do
        @device.update_attributes(
          :alert_on_after_hours => true,
          :after_hours_start => 64800,  # 18:00
          :after_hours_end => 21600     # 06:00
        )

        # update the time of the last point so that we don't cause NOT_REPORTING events
		  @device.points.last.occurred_at = Time.parse("02/05/2009 22:15:00")	  
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

        Mailer.deliveries.length.should.equal 1
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

        Mailer.deliveries.length.should.equal 1
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
          @device.process(@example_location.merge(:time => "00:10:10", :date => "2009/02/06"))
          @device.process(@example_location.merge(:time => "00:32:52", :date => "2009/02/06"))
          @device.process(@example_location.merge(:time => "00:40:00", :date => "2009/02/06"))
        end

        @device.process(@example_location.merge(:time => "00:45:00", :date => "2009/02/05", :event => '6012'))

        Mailer.deliveries.length.should.equal 1

        # New trip
        Trip.should.differ(:count).by(1) do
          Event.should.differ(:count).by(3) do
            @device.process(@example_location.merge(:time => "02:00:00", :date => "2009/02/06", :event => '6011'))
            @device.process(@example_location.merge(:time => "02:10:00", :date => "2009/02/06", :event => '4001'))
            @device.process(@example_location.merge(:time => "02:20:00", :date => "2009/02/06", :event => '6001'))
          end
        end

        @device.process(@example_location.merge(:time => "02:30:00", :date => "2009/02/06", :event => '6012'))

        # Should have alerted on the Ignition On
        Mailer.deliveries.length.should.equal 2

        # some periodic reports while stationary
        @device.process(@example_location.merge(:time => "04:30:00", :date => "2009/02/06", :event => '4002'))
        @device.process(@example_location.merge(:time => "06:30:00", :date => "2009/02/06", :event => '4002'))
        @device.process(@example_location.merge(:time => "08:30:00", :date => "2009/02/06", :event => '4002'))
        @device.process(@example_location.merge(:time => "10:30:00", :date => "2009/02/06", :event => '4002'))


        # No longer after-hours
        Trip.should.differ(:count).by(1) do
          Event.should.differ(:count).by(0) do
            @device.process(@example_location.merge(:time => "11:01:00", :date => "2009/02/06", :event => '6011'))
            @device.process(@example_location.merge(:time => "11:20:00", :date => "2009/02/06"))
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
          @device.process(@example_location.merge(:time => "00:10:10", :date => "2009/02/06"))
          @device.process(@example_location.merge(:time => "01:32:52", :date => "2009/02/06"))
          @device.process(@example_location.merge(:time => "02:30:30", :date => "2009/02/06"))
        end

        @device.trips.last.points.each do |point|
          assert point.events.exists?(:event_type => Event::AFTER_HOURS)
        end
      end
    end
    
    context "VIN Mismatch Alerts" do
      setup do
        @device.update_attribute(:vin_number, '1111')
        @device.update_attribute(:lock_vin, true)
        Mailer.deliveries.clear
      end

      specify "nothing set if lock_vin isn't set" do
        @device.update_attribute(:lock_vin, false)
        @device.update_attribute(:alert_on_reset, false)

        # Event::RESET
        @device.process(@example_location.merge(:event => '6015', :vin => '2222'))
        @device.vin_number.should.equal '2222'

        # Normal event
        @device.process(@example_location.merge(:event => '4001', :vin => '2233'))
        @device.vin_number.should.equal '2233'

        Mailer.deliveries.length.should.equal 0
        @device.points.last.events.count.should.equal 0
      end
      
      specify "sends alerts if vin number does not match" do
        @device.process(@example_location.merge(:event => '6015', :vin => '2222'))
        @device.vin_number.should.equal '1111'
        
        Mailer.deliveries.length.should.equal 1
        Mailer.deliveries.first.body.should =~ /VIN Mismatch/
      end
      
      specify "only sends the alert on power-up, not on heartbeat" do
        @device.process(@example_location.merge(:event => '4006', :vin => '2222'))
        
        Mailer.deliveries.length.should.equal 0
      end
      
      specify "adds vin mismatch events to points" do
        @device.process(@example_location.merge(:event => '4001', :vin => '2222'))
        
        @device.points.last.events.first.event_type.should.equal Event::VIN_MISMATCH
      end
      
      specify "do not add events if vin or reported vin is blank" do
        @device.update_attribute(:vin_number, nil)
        @device.process(@example_location.merge(:event => '4001', :vin => '2222'))
        @device.points.reload.last.events.length.should.equal 0
        
        @device.update_attribute(:vin_number, '1111')
        @device.process(@example_location.merge(:event => '4001', :vin => ''))
        @device.points.reload.last.events.length.should.equal 0
      end
    end

#    context "Device Power Reset Alerts" do
#      setup do
#        Mailer.deliveries.clear
#        @example_location[:event] = '6015'
#      end
#
#      specify "create events for power reset" do
#        Event.should.differ(:count).by(1) do
#          @device.process(@example_location)
#        end
#        Mailer.deliveries.length.should.be 0
#      end
#
#      specify "send alerts for power reset" do
#        Event.should.differ(:count).by(1) do
#          @device.process(@example_location)
#        end
#        Mailer.deliveries.length.should.be 1
#      end
#    end

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
    @device.position.should.equal points(:quentin_point2)

    @device.points.delete_all
    @device.reload.position.should.be.nil
  end

  specify "ignores last positions that have zero lat/long" do
    @device.position.should.equal points(:quentin_point2)
    
    points(:quentin_point2).update_attribute(:latitude, 0)
    @device.reload.position.should.equal points(:quentin_point2)
    
    points(:quentin_point2).update_attribute(:longitude, 0)
    @device.reload.position.should.equal points(:quentin_point)
    
    points(:quentin_point).update_attribute(:latitude, 0)
    points(:quentin_point).update_attribute(:longitude, 0)
    @device.reload.position.should.be.nil
  end
  
  specify "can get current status of device" do
    @device.current_status.should.equal "Moving at 51 mph"

    p = @device.points.create(:speed => 0, :event => '4001', :occurred_at => 10.minutes.from_now,
      :latitude => '-86', :longitude => '42')
    @device.reload
    @device.current_status.should.equal "Idle"

    @device.points.create(:speed => 0, :event => '6012', :occurred_at => 20.minutes.from_now,
      :latitude => '-86', :longitude => '42')
    @device.reload
    @device.current_status.should.equal "Stationary"

    @device.points.clear
    @device.reload
    @device.current_status.should.equal "No Data"
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

  specify "allows device_profile_id=, but enforces account ownership" do
    @device.update_attributes(:device_profile_id => nil)
    @device.device_profile.should.be.nil
    
    @device.update_attributes(:device_profile_id => device_profiles(:quentin).id)
    @device.device_profile.should.equal device_profiles(:quentin)
    
    should.raise(ActiveRecord::RecordNotFound) do
      @device.update_attributes(:device_profile_id => device_profiles(:aaron).id)
    end
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

  context "Aggregating for 'Today'" do
    setup do
      @device.points.clear
      @device.trips.clear
    end

    specify "can get a data aggregator for a given day, giving it the points that fit in the given day" do
      user = users(:quentin)

      t = @device.trips.create
      l = t.legs.create
      l.points.create(
        :event => 4002, :latitude => 33.64512, :longitude => -84.44697,
        :occurred_at => Time.parse("01/01/2009 11:30:00 AM EST"), :miles => 100,
        :device => @device)
      l.points.create(
        :event => 4002, :latitude => 33.64512, :longitude => -84.44697,
        :occurred_at => Time.parse("01/01/2009 11:50:30 AM EST"), :miles => 200,
        :device => @device)
      l.points.create(
        :event => 4002, :latitude => 33.64512, :longitude => -84.44697,
        :occurred_at => Time.parse("01/01/2009 12:30:00 PM EST"), :miles => 300,
        :device => @device)

      data = @device.data_for(Date.parse("01/01/2009"), user.zone)
      data.should.not.be.nil
      data.miles.should.equal 200
    end
  end

  context "Tag Handling" do
    specify "can assign a bunch of tag names to a device" do
      Tag.should.differ(:count).by(3) do
        @device.update_attributes(:tag_names => ['abc', '123', 'baby, you and me'])
      end
      
      @device.reload.tags.length.should.equal 3
      @device.tags.map(&:name).should.equal ['123', 'abc', 'baby, you and me']
    end
    
    specify "will re-use tag names, case insensitive, wherever applicable" do
      Tag.should.differ(:count).by(1) do
        @device.update_attributes(:tag_names => ['personal', 'financial'])
      end
      
      @device.reload.tags.length.should.equal 2
      @device.tags.map(&:name).should.equal ['financial', 'Personal']
    end
    
    specify "strips away extra space and throws away blank tags" do
      Tag.should.differ(:count).by(2) do
        @device.update_attributes(:tag_names => ['abc', ' 123 ', ' personal ', ' ', '  '])
      end
      
      @device.reload.tags.length.should.equal 3
      @device.tags.map(&:name).should.equal ['123', 'abc', 'Personal']
    end
    
    specify "handles tag collisions and duplicates" do
      Tag.should.differ(:count).by(1) do
        @device.update_attributes(:tag_names => [' abc ', 'abc ', 'abc', ' ABC '])
      end
      
      @device.reload.tags.length.should.equal 1
      @device.tags.map(&:name).should.equal ['abc']
    end
  end
  
  context "Handling Device Profile" do
    specify "device prefills fields from profile when saved" do
      # Device has a profile, so I shouldn't be able to change profile fields
      @device.update_attributes(:device_profile => device_profiles(:quentin))
      @device.update_attributes(:name => 'XYZ', :alert_on_speed => false)
      @device.reload.alert_on_speed.should.equal true
      @device.name.should.equal 'XYZ'
      
      @device.update_attributes(:device_profile => nil, :alert_on_speed => false)
      @device.reload.alert_on_speed.should.equal false
    end
  end
end
