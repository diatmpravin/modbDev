require 'test_helper'

describe "Geofences Controller", ActionController::TestCase do
  use_controller GeofencesController
  
  setup do
    login_as :quentin
    @account = accounts(:quentin)
    @device = devices(:quentin_device)
  end

  context "Index - HTML" do

    specify "shows list of geofences" do
      get :index
      template.should.be 'index'

      assigns(:geofences).should.equal [geofences(:quentin_geofence)]
    end

    specify "handles pagination" do
      g = geofences(:quentin_geofence)
      50.times { g.clone.save}

      get :index
      template.should.be 'index'

      assigns(:geofences).length.should.equal 30

      get :index, :page => 2
      template.should.be 'index'

      assigns(:geofences).length.should.equal 21
    end

    specify "works with Geofence filter criteria" do
      set_filter Device, "get_vehicle"
      set_filter Geofence, "geo_find"

      Geofence.expects(:search).with(
        "geo_find", :conditions => {}, 
        :page => nil, :per_page => 30,
        :with => {:account_id => accounts(:quentin).id}, 
        :mode => :extended
      ).returns(accounts(:quentin).geofences)

      get :index
      template.should.be 'index'

      assigns(:geofences).length.should.be 1
    end

  end
  
#  context "Index - JSON" do
#    specify "get list of geofences" do
#      get :index, :format => 'json'
#
#      json.length.should.be 1
#      json[0]['geofence']['id'].should.equal geofences(:quentin_geofence).id
#    end
#
#    specify "returns device-specific geofences if device is specified" do
#      @account.geofences.create(:name => 'Test', :radius => 3)
#      assert @account.geofences.length > 1
#      
#      get :index, :device_id => @device.id, :format => 'json'
#      
#      json.length.should.be 1
#      json[0]['geofence']['id'].should.equal geofences(:quentin_geofence).id
#    end
#
#    specify "geofences should include list of linked devices" do
#      @account.geofences.create(:name => 'Test', :radius => 3)
#      assert @account.geofences.length > 1
#
#      get :index, :format => 'json'
#
#      json.length.should.be 2
#      json[0]['geofence']['device_ids'].should.equal [@device.id]
#      json[1]['geofence']['device_ids'].should.equal []
#    end
#    
#    specify "errors out if device belongs to a different account" do
#      should.raise ActiveRecord::RecordNotFound do
#        get :index, {
#          :device_id => devices(:aaron_device).id,
#          :format => 'json'
#        }
#      end
#    end
#  end
  
  context "Creating a geofence" do
    specify "displays new geofence form" do
      get :new
      
      template.should.be 'new'

      has :geofence
    end
    
    xspecify "works" do
      Geofence.should.differ(:count).by(1) do
        post :create, {
          :geofence => {
            :name => 'Test',
            :type => 0,
            :radius => 15,
            :coordinates => [
              {:latitude => 50, :longitude => 50},
              {:latitude => 100, :longitude => 100},
              {:latitude => 0, :longitude => 0}
            ]
          },
          :format => 'json'
        }
      end
      
      json['status'].should.equal 'success'
      json['view'].should =~ /<h2>Test<\/h2>/
      json['edit'].should =~ /value="Test"/
      
      @account.reload.geofences.length.should.be 2
      @account.geofences.last.coordinates.should.equal [
        {:latitude => 50, :longitude => 50},
        {:latitude => 100, :longitude => 100},
        {:latitude => 0, :longitude => 0}
      ]
    end
    
    xspecify "handles errors gracefully" do
      post :create, {
        :geofence => {
          :type => 0,
          :radius => 15,
          :coordinates => [
            {:latitude => 50, :longitude => 50},
            {:latitude => 100, :longitude => 100},
            {:latitude => 0, :longitude => 0}
          ]
        },
        :format => 'json'
      }
      
      json['status'].should.equal 'failure'
      json['html'].should =~ /can't be blank/
    end
  end
  
  context "Updating a geofence" do
    setup do
      @geofence = geofences(:quentin_geofence)
    end
    
    specify "displays edit geofence form" do
      get :edit, :id => @geofence.id
      
      template.should.be 'edit'
      
      assigns(:geofence).should.equal @geofence
    end
    
    xspecify "works" do
      @geofence.update_attribute(:name, 'test 1')
      put :update, {
        :id => @geofence.id,
        :geofence => {
          :name => 'test 2'
        },
        :format => 'json'
      }
      
      json['status'].should.equal 'success'
      json['view'].should =~ /<h2>test 2<\/h2>/
      json['edit'].should =~ /value="test 2"/
      
      @geofence.reload.name.should.equal 'test 2'
    end
    
    xspecify "handles errors gracefully" do
      put :update, {
        :id => @geofence.id,
        :geofence => {
          :name => ''
        }
      }
      
      json['status'].should.equal 'failure'
      json['html'].should =~ /can't be blank/
    end
  end
  
  context "Destroying a geofence" do
    setup do
      @geofence = geofences(:quentin_geofence)
    end
    
    specify "works" do
      delete :destroy, :id => @geofence.id
      should.redirect_to geofences_path
    end
  end
end
