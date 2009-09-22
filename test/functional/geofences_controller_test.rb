require 'test_helper'

describe "Geofences Controller", ActionController::TestCase do
  use_controller GeofencesController
  
  setup do
    login_as :quentin
    @account = accounts(:quentin)
    @device = devices(:quentin_device)
  end
  
  context "Getting a list of geofences" do
    specify "works" do
      get :index, :format => 'json'

      json.length.should.be 1
      json[0]['geofence']['id'].should.equal geofences(:quentin_geofence).id
    end

    xspecify "requires working subscription (cancelled)" do
      @account.subscription.update_attribute(:status, "cancelled")
      get :index
      should.redirect_to edit_account_path
    end
    
    specify "returns device-specific geofences if device is specified" do
      @account.geofences.create(:radius => 3)
      assert @account.geofences.length > 1
      
      get :index, :device_id => @device.id, :format => 'json'
      
      json.length.should.be 1
      json[0]['geofence']['id'].should.equal geofences(:quentin_geofence).id
    end
    
    specify "errors out if device belongs to a different account" do
      should.raise ActiveRecord::RecordNotFound do
        get :index, {
          :device_id => devices(:aaron_device).id,
          :format => 'json'
        }
      end
    end
  end
  
  context "Creating a geofence" do
    specify "displays new geofence form" do
      get :new
      
      template.should.be 'new'
      assigns(:devices).should.equal @account.devices
    end
    
    specify "works" do
      Geofence.should.differ(:count).by(1) do
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
      end
      
      json['status'].should.equal 'success'
      
      @account.reload.geofences.length.should.be 2
      @account.geofences.last.coordinates.should.equal [
        {:latitude => 50, :longitude => 50},
        {:latitude => 100, :longitude => 100},
        {:latitude => 0, :longitude => 0}
      ]
    end
    
    specify "handles errors gracefully" do
      Geofence.any_instance.expects(:save).returns(false)
      post :create, {
        :geofence => {
          :type => 0
        },
        :format => 'json'
      }
      
      json['status'].should.equal 'failure'
    end
  end
  
  context "Updating a geofence" do
    setup do
      @geofence = geofences(:quentin_geofence)
    end
    
    specify "displays edit geofence form" do
      get :edit, {
        :id => @geofence.id
      }
      
      template.should.be 'edit'
      assigns(:devices).should.equal accounts(:quentin).devices
    end
    
    specify "works" do
      @geofence.update_attribute(:name, 'test 1')
      put :update, {
        :id => @geofence.id,
        :geofence => {
          :name => 'test 2'
        },
        :format => 'json'
      }
      
      json['status'].should.equal 'success'
      @geofence.reload.name.should.equal 'test 2'
    end
    
    specify "handles errors gracefully" do
      Geofence.any_instance.expects(:save).returns(false)
      put :update, {
        :id => @geofence.id,
        :geofence => {
          :name => 'hello'
        }
      }
      
      json['status'].should.equal 'failure'
    end
  end
  
  context "Destroying a geofence" do
    setup do
      @geofence = geofences(:quentin_geofence)
    end
    
    specify "works" do
      delete :destroy, {
        :id => @geofence.id
      }
      
      json['status'].should.equal 'success'
      Geofence.find_by_id(@geofence.id).should.be.nil
    end
  end
end
