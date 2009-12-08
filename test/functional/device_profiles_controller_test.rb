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
end
