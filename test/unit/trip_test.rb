require 'test_helper'

describe "Trip", ActiveSupport::TestCase do
  setup do
    # Sort out all the precalc fields that would be filled in
    points(:quentin_point2).update_precalc_fields
    
    @device = devices(:quentin_device)
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
  
  context "Updating precalc fields" do
    setup do
      @point1 = points(:quentin_point)
      @point2 = points(:quentin_point2)
    end
  
    specify "updates start time" do
      time = Time.parse('01/01/1980 04:30:00 UTC')
      @trip.legs[0].points << Point.new(:occurred_at => time,
        :miles => 30,
        :device => @device)
      @trip.reload.start.should.equal time
    end
    
    specify "updates finish time and miles" do
      time = Time.parse('01/01/2010 04:30:00 UTC')
      @trip.legs[0].points << Point.new(:occurred_at => time,
        :miles => 30,
        :device => @device)
      @trip.reload.finish.should.equal time
    end
    
    specify "updates miles" do
      @point2.update_attribute(:miles, 80)
      @trip.reload.miles.should.equal 63
    end
    
    specify "updates miles, handling mile rollover" do
      @point2.update_attribute(:miles, 7)
      @trip.reload.miles.should.equal 9990
    end
    
    specify "updates idle time" do
      @trip.legs[0].points << Point.new(
        :occurred_at => Time.parse('01/01/2010 04:30:00 UTC'),
        :miles => 30,
        :speed => 0,
        :device => @device
      )
      @trip.legs[0].points << Point.new(
        :occurred_at => Time.parse('01/01/2010 04:35:00 UTC'),
        :miles => 30,
        :speed => 25,
        :device => @device
      )
      
      @trip.reload.idle_time.should.equal 300
    end
    
    specify "updates average miles per gallon" do
      # Simple interval test: whole mpgs at 15 minutes apart
      @trip.legs[0].points << Point.new(
        :occurred_at => Time.parse('02/05/2009 08:30:00 UTC'),
        :miles => 50,
        :mpg => 26,
        :device => @device
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
        :mpg => 7,
        :device => @device
      )
      @trip.legs[0].points << Point.new(
        :occurred_at => Time.parse('02/05/2009 08:01:30 UTC'),
        :miles => 50,
        :mpg => 9,
        :device => @device
      )
      @trip.legs[0].points << Point.new(
        :occurred_at => Time.parse('02/05/2009 08:03:30 UTC'),
        :miles => 50,
        :mpg => 15,
        :device => @device
      )
      @trip.legs[0].points << Point.new(
        :occurred_at => Time.parse('02/05/2009 08:05:30 UTC'),
        :miles => 50,
        :mpg => 18,
        :device => @device
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
    end
    
    specify "knows average rpm" do
      @trip.average_rpm.should.equal 2056
    end
  end
  
  context "Collapsing a trip" do
    setup do
      @t = devices(:quentin_device).trips.create
      leg = @t.legs.create
      
      leg.points << Point.create(
        :event => 4001,
        :latitude => 33.68,
        :longitude => -84.40,
        :mpg => 20,
        :miles => 30,
        :occurred_at => Time.parse('02/05/2009 08:17:00 UTC'),
        :device => @device
      )
      leg.points << Point.create(
        :event => 4001,
        :latitude => 33.68,
        :longitude => -84.40,
        :mpg => 22,
        :miles => 35,
        :occurred_at => Time.parse('02/05/2009 08:27:00 UTC'),
        :device => @device
      )
    end
    
    specify "legs on the trip are moved to the collapsed trip" do
      @trip.legs.length.should.equal 1
      @t.collapse.should.equal @trip
      @trip.reload.legs.length.should.equal 2
      
      Trip.find_by_id(@t.id).should.be.nil
    end
    
    specify "update data runs correctly on the collapsed trip" do
      # Sanity check on prior values
      @trip.miles.should.equal 6
      @trip.finish.should.equal Time.parse('02/05/2009 08:15:00 UTC')
      @trip.idle_time.should.equal 0
      @trip.average_mpg.should.equal BigDecimal.new('20')
      
      # Test
      @t.collapse.should.equal @trip
      @trip.reload
      
      @trip.miles.should.equal 11
      @trip.finish.should.equal Time.parse('02/05/2009 08:27:00 UTC')
      @trip.idle_time.should.equal 0
      @trip.average_mpg.should.equal BigDecimal.new('20.4')
    end
    
    specify "collapsed trip inherits all tags (but no duplicate rows)" do
      tag1 = accounts(:quentin).tags.create(:name => 'Tag 1')
      tag2 = accounts(:quentin).tags.create(:name => 'Tag 2')
      tag3 = accounts(:quentin).tags.create(:name => 'Tag 3')
      tag4 = accounts(:quentin).tags.create(:name => 'Tag 4')
      
      @trip.update_attributes(:tags => [tag1, tag2])
      @t.update_attributes(:tags => [tag2, tag4])
      
      @t.collapse.should.equal @trip
      
      @trip.reload
      @trip.tags.length.should.equal 3
      @trip.tags.should.include(tag1)
      @trip.tags.should.include(tag2)
      @trip.tags.should.not.include(tag3)
      @trip.tags.should.include(tag4)
    end
    
    specify "the first trip in the list can't collapse" do
      @trip.should.not.collapse
    end
  end
  
  context "Expanding a trip" do
    setup do
      # Use the same test data from the collapse tests, but pre-collapse it.
      t = @device.trips.create
      leg = t.legs.create
      
      leg.points << Point.create(
        :event => 4001,
        :latitude => 33.68,
        :longitude => -84.40,
        :mpg => 20,
        :miles => 30,
        :occurred_at => Time.parse('02/05/2009 08:17:00 UTC'),
        :device => @device
      )
      leg.points << Point.create(
        :event => 4001,
        :latitude => 33.68,
        :longitude => -84.40,
        :mpg => 22,
        :miles => 35,
        :occurred_at => Time.parse('02/05/2009 08:27:00 UTC'),
        :device => @device
      )
      
      t.collapse
      @trip.reload
    end
    
    specify "the last leg of the trip is moved into a new trip" do
      @device.trips.length.should.equal 1
      @trip.legs.length.should.equal 2
      
      leg = @trip.legs.last
      
      new_trip = @trip.expand
      new_trip.device.should.equal @device
      new_trip.legs.should.equal [leg]
      
      @device.trips.reload.length.should.equal 2
      @trip.legs.reload.length.should.equal 1
    end
    
    specify "update data runs correctly on both trips" do
      # Sanity check on the "collapsed" values
      @trip.miles.should.equal 11
      @trip.finish.should.equal Time.parse('02/05/2009 08:27:00 UTC')
      @trip.idle_time.should.equal 0
      @trip.average_mpg.should.equal BigDecimal.new('20.4')
      
      new_trip = @trip.expand
      
      # Test the "old" (expanded from) trip
      @trip.miles.should.equal 6
      @trip.finish.should.equal Time.parse('02/05/2009 08:15:00 UTC')
      @trip.idle_time.should.equal 0
      @trip.average_mpg.should.equal BigDecimal.new('20')
      
      # Test the "new" (expanded out) trip
      new_trip.miles.should.equal 5
      new_trip.start.should.equal Time.parse('02/05/2009 08:17:00 UTC')
      new_trip.finish.should.equal Time.parse('02/05/2009 08:27:00 UTC')
      new_trip.idle_time.should.equal 0
      new_trip.average_mpg.should.equal BigDecimal.new('21')
    end
    
    specify "new trip inherits all tags" do
      tag1 = accounts(:quentin).tags.create(:name => 'Tag 1')
      tag2 = accounts(:quentin).tags.create(:name => 'Tag 2')
      tag3 = accounts(:quentin).tags.create(:name => 'Tag 3')
      
      @trip.update_attributes(:tags => [tag1, tag2])
      
      new_trip = @trip.expand
      
      new_trip.tags.should.include(tag1)
      new_trip.tags.should.include(tag2)
      new_trip.tags.should.not.include(tag3)
    end
    
    specify "trips with only one leg can't expand" do
      new_trip = @trip.expand
      
      # Now both trips have one leg each
      @trip.should.not.expand
      new_trip.should.not.expand
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
