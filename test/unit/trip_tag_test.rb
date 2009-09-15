require 'test_helper'

describe "Trip Tag", ActiveSupport::TestCase do
  setup do
    @trip = trips(:quentin_trip)
    @tag = tags(:quentin_tag)
    @tt = trip_tags(:quentin_tt)
  end
  
  context "Associations" do
    specify "belongs to a trip" do
      @tt.should.respond_to(:trip)
      @tt.trip.should.equal @trip
    end
    
    specify "belongs to a tag" do
      @tt.should.respond_to(:tag)
      @tt.tag.should.equal @tag
    end
  end
  
  specify "protects appropriate attributes" do
    tt = TripTag.new(:trip_id => @trip.id, :tag_id => @tag.id)
    tt.trip_id.should.be.nil
    tt.tag_id.should.be.nil
    
    tt = TripTag.new(:trip => @trip, :tag => @tag)
    tt.trip_id.should.equal @trip.id
    tt.tag_id.should.equal @tag.id
  end
end
