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
  end
  
  specify "protects appropriate attributes" do
    leg = Leg.new(:trip_id => 7)
    leg.trip_id.should.be.nil
    
    leg = Leg.new(:trip => trips(:quentin_trip))
    leg.trip_id.should.equal(trips(:quentin_trip).id)
  end
end
