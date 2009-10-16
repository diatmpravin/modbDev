require 'test_helper'

describe "Trip", ActiveSupport::TestCase do
  setup do
    @trip = trips(:quentin_trip)
  end
  
  context "Associations" do
    specify "has many legs" do
      @trip.should.respond_to(:legs)
      @trip.legs.should.include(legs(:quentin_leg))
    end
    
    specify "has many points" do
      @trip.should.respond_to(:points)
      @trip.points.should.include(points(:quentin_point))
    end
    
    specify "belongs to a device" do
      @trip.should.respond_to(:device)
      @trip.device.should.equal devices(:quentin_device)
    end
    
    specify "has many tags" do
      @trip.should.respond_to(:tags)
      @trip.tags.should.include tags(:quentin_tag)
    end
  end
  
  context "Scopes" do
    context "in_range scope" do
      setup do
        @trip1 = Trip.create(
          :start => Time.parse('01/01/2009 23:59:59 EST'),
          :finish => Time.parse('01/04/2009 00:00:00 EST')
        )
        @trip2 = Trip.create(
          :start => Time.parse('01/31/2009 00:00:00 EST'),
          :finish => Time.parse('01/31/2009 23:59:59 EST')
        )
        @trip3 = Trip.create(
          :start => Time.parse('02/01/2009 23:59:59 EST'),
          :finish => Time.parse('02/02/2009 00:00:00 EST')
        )
        @trip4 = Trip.create(
          :start => Time.parse('02/02/2009 00:00:00 EST'),
          :finish => Time.parse('02/02/2009 23:59:59 EST')
        )
      end
      
      specify "works for trips barely at end of range" do
        zone = ActiveSupport::TimeZone['Eastern Time (US & Canada)']
        list = Trip.in_range(Date.parse('02/01/2009'), Date.parse('02/01/2009'), zone)
        list.should.not.include(@trip2)
        list.should.include(@trip3)
        list.should.not.include(@trip4)
      end
      
      specify "works for trips barely at start of range" do
        zone = ActiveSupport::TimeZone['Eastern Time (US & Canada)']
        list = Trip.in_range(Date.parse('02/02/2009'), Date.parse('02/02/2009'), zone)
        list.should.not.include(@trip2)
        list.should.include(@trip3)
        list.should.include(@trip4)
      end
      
      specify "works for trips spanning the date range" do
        zone = ActiveSupport::TimeZone['Eastern Time (US & Canada)']
        list = Trip.in_range(Date.parse('01/02/2009'), Date.parse('01/03/2009'), zone)
        list.should.include(@trip1)
      end
      
      specify "respects time zone changes" do
        zone = ActiveSupport::TimeZone['Central Time (US & Canada)']
        list = Trip.in_range(Date.parse('02/02/2009'), Date.parse('02/02/2009'), zone)
        list.should.not.include(@trip2)
        list.should.not.include(@trip3) # this trip gets knocked into the previous day
        list.should.include(@trip4)
      end
    end
  end
  
  specify "protects appropriate attributes" do
    trip = Trip.new(:device_id => 7)
    trip.device_id.should.be.nil
    
    trip = Trip.new(:device => devices(:quentin_device))
    trip.device_id.should.equal devices(:quentin_device).id
  end
  
  specify "calculates total miles for trip" do
    @trip.legs[0].points.clear
    @trip.legs[0].points << Point.new(:miles => 30,
      :occurred_at => Date.parse('02/01/2009'))
    @trip.legs[0].points << Point.new(:miles => 61,
      :occurred_at => Date.parse('02/02/2009'))
    
    @trip.reload.miles.should.equal 31
    
    @trip.legs[0].points.clear
    @trip.legs[0].points << Point.new(:miles => Device::ROLLOVER_MILES - 1,
      :occurred_at => Date.parse('02/01/2009'))
    @trip.legs[0].points << Point.new(:miles => 7,
      :occurred_at => Date.parse('02/02/2009'))
    
    @trip.reload.miles.should.equal 8
  end
  
  specify "defaults start and finish to current time on creation" do
    Time.freeze(Time.parse('02/05/2009 12:30:00 UTC')) do |t|
      trip = Trip.new
      trip.start.should.equal t
      trip.finish.should.equal t
      
      time = Time.parse('02/01/2009 04:00:00 UTC')
      trip = Trip.new(:start => time, :finish => time)
      trip.start.should.equal time
      trip.finish.should.equal time
    end
  end
  
  context "Updating data from points" do
    specify "updates start time" do
      time = Time.parse('01/01/1980 04:30:00 UTC')
      @trip.legs[0].points << Point.new(:occurred_at => time,
        :miles => 30)
      
      @trip.reload.start.should.equal time
    end
    
    specify "updates finish time and miles" do
      time = Time.parse('01/01/2010 04:30:00 UTC')
      
      @trip.points.first.update_attribute(:miles, 45)
      @trip.legs[0].points << Point.new(:occurred_at => time,
        :miles => 56)
      
      @trip.reload.finish.should.equal time
      @trip.miles.should.equal 11
    end
    
    specify "updates idle time" do
      @trip.legs[0].points << Point.new(
        :occurred_at => Time.parse('01/01/2010 04:30:00 UTC'),
        :miles => 30,
        :speed => 0
      )
      @trip.legs[0].points << Point.new(
        :occurred_at => Time.parse('01/01/2010 04:35:00 UTC'),
        :miles => 30,
        :speed => 25
      )
      
      @trip.reload.idle_time.should.equal 300
    end
    
    specify "updates average miles per gallon" do
      # Simple interval test: whole mpgs at 15 minutes apart
      @trip.legs[0].points << Point.new(
        :occurred_at => Time.parse('02/05/2009 08:30:00 UTC'),
        :miles => 50,
        :mpg => 26
      )
      @trip.reload.average_mpg.should.equal 22
      
      # Single point test (should return the only mpg point we have)
      @trip.legs[0].points.last.destroy
      @trip.legs[0].points.last.destroy
      @trip.legs[0].points[0].update_attributes(:mpg => 7)
      @trip.reload.average_mpg.should.equal 7
      
      # Variable interval test: 1 min, 30 sec, 2 min, 2 min
      estimated_mpg = (3.5*1 + 8*0.5 + 12*2 + 16.5*2) / 5.5
      estimated_mpg = BigDecimal.new(estimated_mpg.to_s).floor(1)
      
      @trip.legs[0].points[0].update_attributes(:mpg => 0)
      @trip.legs[0].points << Point.new(
        :occurred_at => Time.parse('02/05/2009 08:01:00 UTC'),
        :miles => 50,
        :mpg => 7
      )
      @trip.legs[0].points << Point.new(
        :occurred_at => Time.parse('02/05/2009 08:01:30 UTC'),
        :miles => 50,
        :mpg => 9
      )
      @trip.legs[0].points << Point.new(
        :occurred_at => Time.parse('02/05/2009 08:03:30 UTC'),
        :miles => 50,
        :mpg => 15
      )
      @trip.legs[0].points << Point.new(
        :occurred_at => Time.parse('02/05/2009 08:05:30 UTC'),
        :miles => 50,
        :mpg => 18
      )
      @trip.reload.average_mpg.should.equal estimated_mpg
    end
  end
  
  context "Trip Info Helpers" do
    specify "knows duration of trip" do
      @trip.duration.should.equal 15.minutes
    end
    
    specify "knows max speed" do
      @trip.max_speed.should.equal 61
    end
    
    specify "knows average speed" do
      @trip.average_speed.should.equal 24
      
      @trip.update_attribute(:finish, @trip.start)
      @trip.average_speed.should.equal 0
    end
    
    specify "knows average rpm" do
      @trip.average_rpm.should.equal 2056
    end
  end
  
  specify "can get a list of events" do
    @trip.events.should.include(events(:quentin_event))
  end
  
  specify "allows tag_ids=, but enforces account ownership" do
    tag = tags(:quentin_tag)
    
    @trip.update_attributes(:tag_ids => [])
    @trip.tags.should.be.empty
    
    @trip.update_attributes(:tag_ids => [tag.id])
    @trip.tags.should.include(tag)
    
    should.raise(ActiveRecord::RecordNotFound) do
      bad = tags(:aaron_tag)
      @trip.update_attributes(:tag_ids => [tag.id, bad.id])
    end
  end
end
