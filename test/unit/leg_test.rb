require 'test_helper'

describe "Leg", ActiveSupport::TestCase do
  setup do
    @leg = Leg.new
  end
  
  context "Associations" do
    specify "belongs to a trip" do
      @leg.should.respond_to(:trip)
    end
    
    specify "has many points" do
      @leg.should.respond_to(:points)
    end
    
    specify "has many displayable points" do
      @leg = legs(:quentin_leg)
      @leg.displayable_points.should.equal [points(:quentin_point), points(:quentin_point2)]
      
      points(:quentin_point2).update_attributes(:latitude => 0, :longitude => 0)
      @leg.reload.displayable_points.should.equal [points(:quentin_point)]
    end
  end
  
  context "Updating precalc fields" do
    setup do
      @device = devices(:quentin_device)
      @leg = legs(:quentin_leg)
      @point1 = points(:quentin_point)
      @point2 = points(:quentin_point2)
    end
    
    specify "calls trip precalc" do
      Trip.any_instance.expects(:update_precalc_fields)
      @leg.update_precalc_fields
    end
    
    specify "updates start time" do
      time = Time.parse('01/01/1980 04:30:00 UTC')
      @point1.update_attribute(:occurred_at, time)
      @leg.update_precalc_fields
      @leg.reload.start.should.equal time
    end
    
    specify "updates finish time" do
      time = Time.parse('01/01/2010 04:30:00 UTC')
      @point2.update_attribute(:occurred_at, time)
      @leg.update_precalc_fields
      @leg.reload.finish.should.equal time
    end
    
    specify "updates miles" do
      @point2.update_attribute(:miles, 80)
      @leg.update_precalc_fields
      @leg.reload.miles.should.equal 63
    end
    
    specify "updates miles, handling mile rollover" do
      @point2.update_attribute(:miles, 7)
      @leg.update_precalc_fields
      @leg.reload.miles.should.equal 9990
    end
    
    specify "updates idle time" do
      @leg.idle_time.should.equal 0
      
      @leg.points << Point.new(
        :occurred_at => Time.parse('01/01/2010 04:30:00 UTC'),
        :miles => 30,
        :speed => 0,
        :device => @device
      )
      @leg.points << Point.new(
        :occurred_at => Time.parse('01/01/2010 04:35:00 UTC'),
        :miles => 30,
        :speed => 25,
        :device => @device
      )
      
      @leg.update_precalc_fields
      @leg.reload.idle_time.should.equal 300
    end
    
    specify "updates average miles per gallon" do
      # Simple interval test: whole mpgs at 15 minutes apart
      @leg.points << Point.new(
        :occurred_at => Time.parse('02/05/2009 08:30:00 UTC'),
        :miles => 50,
        :mpg => 26,
        :device => @device
      )

      @leg.update_precalc_fields
      @leg.reload.average_mpg.should.equal 26
      
      # Single point test (should return the only mpg point we have)
      @leg.points.last.destroy
      @leg.points.last.destroy
      @leg.points[0].update_attributes(:mpg => 7)
      @leg.update_precalc_fields
      @leg.reload.average_mpg.should.equal 7
      
      @leg.points[0].update_attributes(:mpg => 0)
      @leg.points << Point.new(
        :occurred_at => Time.parse('02/05/2009 08:01:00 UTC'),
        :miles => 50,
        :mpg => 7,
        :device => @device
      )
      @leg.points << Point.new(
        :occurred_at => Time.parse('02/05/2009 08:01:30 UTC'),
        :miles => 50,
        :mpg => 9,
        :device => @device
      )
      @leg.points << Point.new(
        :occurred_at => Time.parse('02/05/2009 08:03:30 UTC'),
        :miles => 50,
        :mpg => 15,
        :device => @device
      )
      @leg.points << Point.new(
        :occurred_at => Time.parse('02/05/2009 08:05:30 UTC'),
        :miles => 50,
        :mpg => 18,
        :device => @device
      )
      
      @leg.update_precalc_fields
      @leg.reload.average_mpg.should.equal 18
    end
  end
  
  specify "protects appropriate attributes" do
    leg = Leg.new(:trip_id => 7)
    leg.trip_id.should.be.nil
    
    leg = Leg.new(:trip => trips(:quentin_trip))
    leg.trip_id.should.equal(trips(:quentin_trip).id)
  end
  
  context "Info Helpers" do
    setup do
      @leg = legs(:quentin_leg)
    end
    
    specify "knows average speed" do
      @leg.average_speed.should.equal 24
      
      @leg.update_attribute(:finish, @leg.start)
      @leg.average_speed.should.equal 0
    end
  end
end
