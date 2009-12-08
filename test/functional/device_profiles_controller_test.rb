require 'test_helper'

describe "Device Profiles Controller", ActionController::TestCase do
  use_controller DeviceProfilesController
  
  setup do
    login_as :quentin
    @account = accounts(:quentin)
    @profile = device_profiles(:quentin)
  end
  
  context "Listing device profiles" do
    specify "works" do
      get :index
      
      template.should.equal 'index'
      assigns(:device_profiles).should.include @profile
    end
  end
  
  context "Creating a device profile" do
    specify "displays the new profile form" do
      get :new
      
      template.should.equal 'new'
      assigns(:device_profile).account.should.equal @account
    end
    
    specify "works" do
      DeviceProfile.should.differ(:count).by(1) do
        post :create, {
          :device_profile => {
            :name => 'My Profile'
          }
        }
      end
      
      should.redirect_to :action => 'index'
      @account.reload.device_profiles.length.should.equal 2
    end
    
    specify "handles errors gracefully" do
      DeviceProfile.should.differ(:count).by(0) do
        post :create, {
          :device_profile => {
            :alert_on_idle => '1'
          }
        }
      end
      
      template.should.equal 'new'
    end
  end
  
  context "Viewing and editing a device profile" do
    specify "displays edit form" do
      get :edit, {
        :id => @profile.id
      }
      
      template.should.equal 'edit'
      assigns(:device_profile).should.equal @profile
    end
    
    specify "works" do
      put :update, {
        :id => @profile.id,
        :device_profile => {
          :name => 'Much Better Name'
        }
      }
      
      should.redirect_to :action => 'index'
      @profile.reload.name.should.equal 'Much Better Name'
    end
    
    specify "handles errors gracefully" do
      put :update, {
        :id => @profile.id,
        :device_profile => {
          :name => ''
        }
      }
      
      template.should.equal 'edit'
      assigns(:device_profile).errors.on(:name).should.equal "can't be blank"
    end
  end
  
  context "Removing a device profile" do
    specify "works" do
      DeviceProfile.should.differ(:count).by(-1) do
        delete :destroy, {
          :id => @profile.id
        }
      end
      
      should.redirect_to :action => 'index'
    end
  end
end
