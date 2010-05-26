require 'test_helper'

describe "DataAggregator", ActiveSupport::TestCase do
  setup do
    @device = devices(:quentin_device)
  end
  
  context "Simple consecutive points" do
    def build
      @trip = Trip.create
      leg = @trip.legs.create
      leg.points.create(:occurred_at => Time.parse("02/01/2009 03:30:15 PM EST"),
                  :speed => 60, :miles => 12000, :mpg => 20,
                  :device => @device)
      leg.points.create(:occurred_at => Time.parse("02/01/2009 03:40:15 PM EST"),
                  :speed => 60, :miles => 12010, :mpg => 20,
                  :device => @device)
      leg.points.create(:occurred_at => Time.parse("02/01/2009 03:50:15 PM EST"),
                  :speed => 60, :miles => 12020, :mpg => 20,
                  :device => @device)
      leg.update_precalc_fields
      @trip.reload
    end

    setup do
      build
      @data = DataAggregator.new

      # This should not create any more trips, legs, or points
      Trip.should.differ(:count).by(0) do
        Leg.should.differ(:count).by(0) do
          Point.should.differ(:count).by(0) do
            @data.trips = [@trip]
          end
        end
      end
    end

    specify "can total distance driven over given points" do
      @data.miles.should.equal 20
    end

    specify "can get overall average MPG" do
      @data.mpg.should.equal 20
    end

    specify "can get total time driven" do
      @data.time.should.equal 20.minutes 
    end

  end


  context "Handling multiple trips" do
    def build_points
      @trips = []
      # 20 minutes
      @trips << (trip = Trip.create)
      leg = trip.legs.create
      leg.points.create(:occurred_at => Time.parse("02/01/2009 03:30:15 PM EST").utc,
                  :speed => 60, :miles => 12000, :mpg => 20,
                  :device => @device)
      leg.points.create(:occurred_at => Time.parse("02/01/2009 03:40:15 PM EST").utc,
                  :speed => 60, :miles => 12010, :mpg => 20,
                  :device => @device)
      leg.points.create(:occurred_at => Time.parse("02/01/2009 03:50:15 PM EST").utc,
                  :speed => 60, :miles => 12020, :mpg => 20,
                  :device => @device)
      leg.update_precalc_fields

      # 10 minutes
      @trips << (trip = Trip.create)
      leg = trip.legs.create
      leg.points.create(:occurred_at => Time.parse("02/01/2009 05:10:00 PM EST").utc,
                  :speed => 60, :miles => 12030, :mpg => 20,
                  :device => @device)
      leg.points.create(:occurred_at => Time.parse("02/01/2009 05:15:00 PM EST").utc,
                  :speed => 60, :miles => 12040, :mpg => 20,
                  :device => @device)
      leg.points.create(:occurred_at => Time.parse("02/01/2009 05:20:00 PM EST").utc,
                  :speed => 60, :miles => 12050, :mpg => 20,
                  :device => @device)
      leg.update_precalc_fields

      # 60 minutes
      @trips << (trip = Trip.create)
      leg = trip.legs.create
      leg.points.create(:occurred_at => Time.parse("02/01/2009 07:00:00 PM EST").utc,
                  :speed => 60, :miles => 12060, :mpg => 20,
                  :device => @device)
      leg.points.create(:occurred_at => Time.parse("02/01/2009 07:30:00 PM EST").utc,
                  :speed => 60, :miles => 12070, :mpg => 20,
                  :device => @device)
      leg.points.create(:occurred_at => Time.parse("02/01/2009 07:45:00 PM EST").utc,
                  :speed => 60, :miles => 12080, :mpg => 20,
                  :device => @device)
      leg.points.create(:occurred_at => Time.parse("02/01/2009 08:00:00 PM EST").utc,
                  :speed => 60, :miles => 12090, :mpg => 20,
                  :device => @device)
      leg.update_precalc_fields

      @trips.each {|t| t.reload }
    end

    setup do
      build_points
      @data = DataAggregator.new
      @data.trips = @trips
    end

    specify "properly aggregates time according to actual driving time, not trip duration" do
      @data.time.should.equal 90 * 60 # time is seconds underneath
    end

  end

end
