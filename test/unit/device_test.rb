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
    
    xspecify "after hours start must be time-formatted" do
      @device.after_hours_start_text = '1:00 am'
      @device.should.be.valid
      
      @device.after_hours_start_text = '02:30pm'
      @device.should.be.valid
      
      @device.after_hours_start_text = 'abcd'
      @device.should.not.be.valid
    end
    
    xspecify "after hours end must be time-formatted" do
      @device.after_hours_end_text = '1:00 am'
      @device.should.be.valid
      
      @device.after_hours_end_text = '02:30pm'
      @device.should.be.valid
      
      @device.after_hours_end_text = 'abcd'
      @device.should.not.be.valid
    end
    
    xspecify "enforces number of records" do
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
        :occurred_at => Time.parse('2009/02/17 09:00:00 UTC'),
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

      specify "only send alerts on points with mph > 5 the previous point" do
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
        @example_location[:speed] = 54
        @example_location[:time] = '12:20:00'
        Event.should.differ(:count).by(1) { @device.process(@example_location) }

        # Alert!
        @example_location[:speed] = 56
        @example_location[:time] = '12:20:20'
        Event.should.differ(:count).by(1) { @device.process(@example_location) }

        # Alert!
        @example_location[:speed] = 70
        @example_location[:time] = '12:20:40'
        Event.should.differ(:count).by(1) { @device.process(@example_location) }

        Mailer.deliveries.length.should.equal 3
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
          @device.process(@example_location.merge(:time => "00:10:10", :date => "2009/02/18"))
          @device.process(@example_location.merge(:time => "00:32:52", :date => "2009/02/18"))
          @device.process(@example_location.merge(:time => "00:40:00", :date => "2009/02/18"))
        end

        @device.process(@example_location.merge(:time => "00:45:00", :date => "2009/02/18", :event => '6012'))

        Mailer.deliveries.length.should.equal 1

        # New trip
        Trip.should.differ(:count).by(1) do
          Event.should.differ(:count).by(3) do
            @device.process(@example_location.merge(:time => "05:00:00", :date => "2009/02/18", :event => '6011'))
            @device.process(@example_location.merge(:time => "05:10:00", :date => "2009/02/18", :event => '4001'))
            @device.process(@example_location.merge(:time => "05:20:00", :date => "2009/02/18", :event => '6001'))
          end
        end

        @device.process(@example_location.merge(:time => "05:30:00", :date => "2009/02/18", :event => '6012'))

        # Should have alerted on the Ignition On
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
    @device.position.should.equal @device.points.last

    @device.points.delete_all
    @device.reload.position.should.be.nil
  end

  specify "can get current status of device" do
    @device.current_status.should.equal "Moving at 51 mph"

    p = @device.points.create :speed => 0, :event => '4001', :occurred_at => 10.minutes.from_now
    @device.reload
    @device.current_status.should.equal "Idle"

    @device.points.create :speed => 0, :event => '6012', :occurred_at => 20.minutes.from_now
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

  context "Aggregating for 'Today'" do
    setup do
      @device.points.clear
      @device.trips.clear
    end

    specify "can get a data aggregator for a given day, giving it the points that fit in the given day" do
      t = @device.trips.create
      l = t.legs.create
      l.points.create(
        :event => 4002, :latitude => 33.64512, :longitude => -84.44697,
        :occurred_at => Time.parse("01/01/2009 11:30:00 AM EST").utc, :miles => 100)
      l.points.create(
        :event => 4002, :latitude => 33.64512, :longitude => -84.44697,
        :occurred_at => Time.parse("01/01/2009 11:50:30 AM EST").utc, :miles => 200)
      l.points.create(
        :event => 4002, :latitude => 33.64512, :longitude => -84.44697,
        :occurred_at => Time.parse("01/01/2009 12:30:00 PM EST").utc, :miles => 300)

      data = @device.data_for(Date.parse("01/01/2009"))
      data.should.not.be.nil
      data.miles.should.equal 200
    end
  end
  
end
