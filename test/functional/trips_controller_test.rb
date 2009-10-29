require 'test_helper'

describe "Trips Controller", ActionController::TestCase do
  use_controller TripsController
  
  setup do
    login_as :quentin
    @account = accounts(:quentin)
    @device = devices(:quentin_device)
  end
  
  context "Getting a list of trips" do
    specify "works" do
      get :index, {
        :device_id => @device.id,
        :start_date => '02/05/2009',
        :end_date => '02/05/2009'
      }
      
      assigns(:device).should.equal @device
      assigns(:trips).should.include trips(:quentin_trip)
      template.should.equal 'index'
    end
    
    specify "works (json)" do
      get :index, {
        :device_id => @device.id,
        :start_date => '02/05/2009',
        :end_date => '02/05/2009',
        :format => 'json'
      }
      
      json['trips'][0]['id'].should.equal trips(:quentin_trip).id
    end
    
    specify "works without a device" do
      get :index, {
        :start_date => '02/05/2009',
        :end_date => '02/05/2009'
      }
      
      assigns(:trips).should.include trips(:quentin_trip)
      template.should.equal 'index'
    end
    
    specify "errors if device is not owned by account" do
      should.raise ActiveRecord::RecordNotFound do
        get :index, {
          :device_id => devices(:aaron_device).id,
          :format => 'json'
        }
      end
    end
  end
  
  context "Showing trip detail" do
    setup do
      @trip = trips(:quentin_trip)
    end
    
    specify "works" do
      get :show, {
        :id => @trip.id
      }
      
      template.should.equal 'show'
      assigns(:trip).should.equal @trip
    end
    
    specify "works (json)" do
      get :show, {
        :id => @trip.id,
        :format => 'json'
      }
      
      json['trip']['id'].should.equal trips(:quentin_trip).id
    end
    
    specify "errors if trip is invalid" do
      should.raise ActiveRecord::RecordNotFound do
        get :show, {
          :id => trips(:aaron_trip),
          :format => 'json'
        }
      end
    end
  end
  
  context "Updating a trip" do
    setup do
      @trip = trips(:quentin_trip)
      @tag = tags(:quentin_tag)
      @trip.tags.clear
    end
    
    specify "displays edit form" do
      get :edit, {
        :id => @trip.id
      }
      
      template.should.equal 'edit'
      assigns(:trip).should.equal @trip
    end
    
    specify "works" do
      post :update, {
        :id => @trip.id,
        :trip => {
          :tag_ids => [@tag.id]
        }
      }
      
      json['status'].should.equal 'success'
    end
    
    specify "handles errors gracefully" do
      Trip.any_instance.expects(:update_attributes).returns(false)
      post :update, {
        :id => @trip.id,
        :trip => {
          :tag_ids => [@tag.id]
        }
      }
      
      json['status'].should.equal 'failure'
      json['error'].should.be.nil
    end
    
    specify "errors if a tag is invalid" do
      should.raise ActiveRecord::RecordNotFound do
        post :update, {
          :id => @trip.id,
          :trip => {
            :tag_ids => [@tag.id, tags(:aaron_tag).id]
          }
        }
      end
    end
  end
  
  context "Collapsing a trip" do
    setup do
      @trip = trips(:quentin_trip)
      
      # Data pulled from trip unit tests.
      leg = Leg.new
      leg.points << Point.new(
        :event => 4001,
        :latitude => 33.68,
        :longitude => -84.40,
        :mpg => 20,
        :miles => 30,
        :occurred_at => Time.parse('02/05/2009 08:17:00 UTC')
      )
      leg.points << Point.new(
        :event => 4001,
        :latitude => 33.68,
        :longitude => -84.40,
        :mpg => 22,
        :miles => 35,
        :occurred_at => Time.parse('02/05/2009 08:27:00 UTC')
      )
      
      @trip2 = devices(:quentin_device).trips.new
      @trip2.legs << leg
      @trip2.save
    end
    
    specify "works" do
      put :collapse, {
        :id => @trip2.id,
        :format => 'json'
      }
      
      json['status'].should.equal 'success'
      json['view'].should =~ /<h4>#{@device.name}<\/h4>/
      json['view'].should =~ /<strong>03:00 AM EST<\/strong>/
      json['edit'].should =~ /<strong>03:00 AM EST<\/strong>/
    end
    
    specify "handles errors gracefully" do
      put :collapse, {
        :id => @trip.id,
        :format => 'json'
      }
      
      json['status'].should.equal 'failure'
    end
  end
  
  context "Expanding a trip" do
    setup do
      @trip = trips(:quentin_trip)
      
      # Data pulled from trip unit tests.
      leg = Leg.new
      leg.points << Point.new(
        :event => 4001,
        :latitude => 33.68,
        :longitude => -84.40,
        :mpg => 20,
        :miles => 30,
        :occurred_at => Time.parse('02/05/2009 08:17:00 UTC')
      )
      leg.points << Point.new(
        :event => 4001,
        :latitude => 33.68,
        :longitude => -84.40,
        :mpg => 22,
        :miles => 35,
        :occurred_at => Time.parse('02/05/2009 08:27:00 UTC')
      )
      
      @trip2 = devices(:quentin_device).trips.new
      @trip2.legs << leg
      @trip2.save
    end
    
    specify "works" do
      @trip2.collapse
      @trip.reload
      
      put :expand, {
        :id => @trip.id,
        :format => 'json'
      }
      
      json['status'].should.equal 'success'
      json['view'].should =~ /<h4>#{@device.name}<\/h4>/
      json['view'].should =~ /<strong>03:00 AM EST<\/strong>/
      json['edit'].should =~ /<strong>03:00 AM EST<\/strong>/
      json['new_trip']['view'].should =~ /<strong>03:17 AM EST<\/strong>/
      json['new_trip']['edit'].should =~ /<strong>03:17 AM EST<\/strong>/
    end
    
    specify "handles errors gracefully" do
      put :expand, {
        :id => @trip.id,
        :format => 'json'
      }
      
      json['status'].should.equal 'failure'
    end
  end
end
