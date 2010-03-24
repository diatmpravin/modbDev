require 'test_helper'

describe "Event", ActiveSupport::TestCase do
  setup do
    @event = events(:quentin_event)
  end
  
  context "Associations" do
    specify "belongs to a point" do
      @event.should.respond_to(:point)
      @event.point.should.equal points(:quentin_point)
    end
  end
  
  context "Scopes" do
    context "in_range scope" do
      setup do
        @event1 = Event.create(:occurred_at => Time.parse('02/01/2009 23:59:59 EST'))
        @event2 = Event.create(:occurred_at => Time.parse('02/02/2009 00:00:00 EST'))
        @event3 = Event.create(:occurred_at => Time.parse('02/03/2009 23:59:59 EST'))
        @event4 = Event.create(:occurred_at => Time.parse('02/04/2009 00:00:00 EST'))
      end
      
      xspecify "works" do
        zone = ActiveSupport::TimeZone['Eastern Time (US & Canada)']
        list = Event.in_range(Date.parse('02/02/2009'), Date.parse('02/03/2009'), zone)
        list.should.not.include(@event1)
        list.should.include(@event2)
        list.should.include(@event3)
        list.should.not.include(@event4)
      end
      
      xspecify "respects time zone changes" do
        zone = ActiveSupport::TimeZone['Central Time (US & Canada)']
        list = Event.in_range(Date.parse('02/02/2009'), Date.parse('02/03/2009'), zone)
        list.should.not.include(@event1)
        list.should.not.include(@event2)
        list.should.include(@event3)
        list.should.include(@event4)
      end
    end
  end
  
  specify "protects appropriate attributes" do
    event = Event.new(:point_id => 7)
    event.point_id.should.be.nil
    
    event = Event.new(:point => points(:quentin_point))
    event.point_id.should.equal points(:quentin_point).id
  end
  
  specify "has a helper for event type text" do
    Event.new(:event_type => Event::ENTER_BOUNDARY).type_text.should.equal 'Enter Boundary'
    Event.new(:event_type => 0).type_text.should.equal 'Unknown'
  end
end
