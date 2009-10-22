require 'test_helper'

describe "Point", ActiveSupport::TestCase do
  setup do
    @point = points(:quentin_point)
  end
  
  context "Associations" do
    specify "belongs to a leg" do
      @point.should.respond_to(:leg)
      @point.leg.should.equal legs(:quentin_leg)
    end
    
    specify "belongs to a device" do
      @point.should.respond_to(:device)
      @point.device.should.equal devices(:quentin_device)
    end
    
    specify "has many events" do
      @point.should.respond_to(:events)
      @point.events.should.include events(:quentin_event)
    end
  end
  
  context "Scopes" do
    context "in_trip scope" do
      specify "works" do
        Point.in_trip.should.include(@point)
        
        @point.update_attribute(:leg, nil)
        Point.in_trip.should.not.include(@point)
      end
      
      specify "provides extension 'trips'" do
        Point.in_trip.trips.should.include(trips(:quentin_trip))
      end
    end
    
    context "in_range scope" do
      setup do
        @point4 = Point.create(:occurred_at => Time.parse('02/04/2009 00:00:00 EST'))
        @point3 = Point.create(:occurred_at => Time.parse('02/03/2009 23:59:59 EST'))
        @point2 = Point.create(:occurred_at => Time.parse('02/02/2009 00:00:00 EST'))
        @point1 = Point.create(:occurred_at => Time.parse('02/01/2009 23:59:59 EST'))
      end
      
      specify "works" do
        zone = ActiveSupport::TimeZone['Eastern Time (US & Canada)']
        list = Point.in_range(Date.parse('02/02/2009'), Date.parse('02/03/2009'), zone)
        list.should.not.include(@point1)
        list.should.include(@point2)
        list.should.include(@point3)
        list.should.not.include(@point4)
      end
      
      specify "respects time zone changes" do
        zone = ActiveSupport::TimeZone['Central Time (US & Canada)']
        list = Point.in_range(Date.parse('02/02/2009'), Date.parse('02/03/2009'), zone)
        list.should.not.include(@point1)
        list.should.not.include(@point2)
        list.should.include(@point3)
        list.should.include(@point4)
      end

      specify "orders in ascending order" do
        zone = ActiveSupport::TimeZone['Central Time (US & Canada)']
        list = Point.in_range(Date.parse('02/01/2009'), Date.parse('02/04/2009'), zone)
        list.should.equal [@point1, @point2, @point3, @point4]
      end
    end
    
    context "trip markers scope" do
      specify "works" do
        @point1 = Point.create(:event => Point::PERIODIC_IGNITION_ON)
        @point2 = Point.create(:event => Point::PERIODIC_IGNITION_OFF)
        @point3 = Point.create(:event => Point::PERIODIC_HEARTBEAT)
        @point4 = Point.create(:event => Point::RESET)
        
        Point.trip_markers.should.include(@point1)
        Point.trip_markers.should.include(@point2)
        Point.trip_markers.should.not.include(@point3)
        Point.trip_markers.should.include(@point4)
      end
    end
  end
  
  specify "protects appropriate attributes" do
    point = Point.new(:leg_id => 7, :device_id => 13)
    point.leg_id.should.be.nil
    point.device_id.should.be.nil
    
    point = Point.new(:leg => legs(:quentin_leg),
      :device => devices(:quentin_device), :event => 3900)
    point.leg_id.should.equal(legs(:quentin_leg).id)
    point.device_id.should.equal(devices(:quentin_device).id)
    point.event.should.equal(3900)
  end
  
  specify "knows if the device is running" do
    @point.event = Point::PERIODIC_IGNITION_ON
    @point.should.be.running
    
    @point.event = Point::PERIODIC_IGNITION_OFF
    @point.should.not.be.running
  end
  
  specify "knows if the point is a trip marker" do
    @point.event = Point::IGNITION_ON
    @point.should.be.trip_marker
    
    @point.event = Point::IGNITION_OFF
    @point.should.be.trip_marker
    
    @point.event = Point::PERIODIC_HEARTBEAT
    @point.should.not.be.trip_marker
  end
  
  context "Parsing location reports" do
    setup do
      @report = {
        :sim => "12345678901234567890",
        :event => "4001",
        :date => "2009/02/17",
        :time => "12:18:54",
        :latitude => "33.64512",
        :longitude => "-84.44697",
        :altitude => "312.1",
        :speed => "31",
        :accelerating => "0",
        :decelerating => "1",
        :rpm => "866",
        :heading => "218.0",
        :satellites => "9",
        :hdop => "1.6",
        :miles => "21"
      }
    end
    
    specify "works" do
      @point.parse(@report)
      
      @point.event.should.equal(4001)
      @point.occurred_at.should.equal(Time.parse('2009/02/17 12:18:54 UTC'))
      @point.latitude.should.equal(BigDecimal.new('33.64512'))
      @point.longitude.should.equal(BigDecimal.new('-84.44697'))
      @point.altitude.should.equal(312)
      @point.speed.should.equal(31)
      @point.should.not.be.accelerating
      @point.should.be.decelerating
      @point.rpm.should.equal(866)
      @point.heading.should.equal(218)
      @point.satellites.should.equal(9)
      @point.hdop.should.equal(BigDecimal.new('1.6'))
      @point.miles.should.equal(21)
    end
    
    specify "works with the new firmware reports" do
      @report[:mpg] = '18.2'
      @report[:battery] = '13.1'
      @report[:signal] = '18'
      @report[:gps] = '1'
      @point.parse(@report)
      
      @point.mpg.should.equal BigDecimal.new('18.2')
      @point.battery.should.equal BigDecimal.new('13.1')
      @point.signal.should.equal 18
      @point.should.be.locked
    end
    
    specify "treats device timestamps as UTC" do
      @report[:time] = '16:00:00'
      @point.parse(@report)
      @point.occurred_at.should.equal(Time.parse('2009/02/17 16:00:00 UTC'))
      
      @report[:date] = '2009/05/10'
      @point.parse(@report)
      @point.occurred_at.should.equal(Time.parse('2009/05/10 16:00:00 UTC'))
    end
  end
  
  context "Updating associated trip timestamps" do
    specify "works" do
      Trip.any_instance.expects(:update_point_data)
      @point.should.save
    end
    
    specify "skips updates if there is no trip" do
      Trip.any_instance.expects(:update_point_data).never
      @point.leg = nil
      @point.should.save
    end
  end
  
  specify "knows the time of day as a string" do
    @point.device.account.update_attributes(:time_zone => 'Eastern Time (US & Canada)') 
    @point.occurred_at = Time.parse('2009/01/01 17:15:30 UTC')
    @point.time_of_day.should.equal '12:15 PM EST'
    
    @point.occurred_at = Time.parse('2009/04/01 17:15:30 UTC')
    @point.time_of_day.should.equal '01:15 PM EDT'
  end
end
