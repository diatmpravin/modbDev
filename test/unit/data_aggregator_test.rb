require 'test_helper'

describe "DataAggregator", ActiveSupport::TestCase do

  def build_points
    @points = []
    @points << Point.create(:occurred_at => Time.parse("02/01/2009 03:30:15 PM EST").utc,
                :speed => 60, :miles => 12000, :mpg => 20)
    @points << Point.create(:occurred_at => Time.parse("02/01/2009 03:40:15 PM EST").utc,
                :speed => 60, :miles => 12010, :mpg => 20)
    @points << Point.create(:occurred_at => Time.parse("02/01/2009 03:50:15 PM EST").utc,
                :speed => 60, :miles => 12020, :mpg => 20)
  end

  setup do
    build_points
    @data = DataAggregator.new

    # This should not create any more trips, legs, or points
    Trip.should.differ(:count).by(0) do
      Leg.should.differ(:count).by(0) do
        Point.should.differ(:count).by(0) do
          @data.points = @points
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
