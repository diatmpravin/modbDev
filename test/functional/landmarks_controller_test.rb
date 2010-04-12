require 'test_helper'

describe "Landmarks Controller", ActionController::TestCase do
  use_controller LandmarksController
  
  setup do
    login_as :quentin
    @account = accounts(:quentin)
    @landmark = landmarks(:quentin)
    @device = devices(:quentin_device)
  end
  
  context "Listing landmarks" do
    specify "redirects to dashboard" do
      get :index
      
      should.redirect_to dashboard_path(:anchor => 'landmarks')
    end
  end
  
  context "Creating a landmark" do
    specify "displays the new landmark form" do
      get :new
      
      template.should.equal 'new'
      assigns(:landmark).should.not.be.nil
    end
    
    specify "works (json)" do
      Landmark.should.differ(:count).by(1) do
        post :create, {
          :format => 'json',
          :landmark => 
            {
              :name => 'My Landmark',
              :latitude => '39.267',
              :longitude => '-86.9074'
            }
        }
      end

      json['status'].should.equal 'success'
      
      @account.reload.landmarks.length.should.equal 2
      @account.landmarks.last.latitude.should.equal BigDecimal.new('39.267')
      @account.landmarks.last.longitude.should.equal BigDecimal.new('-86.9074')
    end
    
    specify "handles errors gracefully (json)" do
      post :create, {
        :format => 'json',
        :landmark => 
          {
            :latitude => '39.267',
            :longitude => '-86.9074'
          }
      }

      json['status'].should.equal 'failure'
      json['html'].should =~ /<form/
      
      assigns(:landmark).should.not.be.nil
    end
    
    specify "correctly handles spaces entered in lat/long (json)" do
      post :create, {
        :format => 'json',
        :id => @landmark.id,
        :landmark => 
          {
            :name => 'Test',
            :latitude => '   -86.347   ',
            :longitude => '   42.04   '
          }
      }

      json['status'].should.equal 'success'
    end
  end
  
  context "Viewing and editing a landmark" do
    specify "displays edit form" do
      get :edit, {
        :id => @landmark.id
      }
      
      template.should.equal 'edit'
      assigns(:landmark).should.equal @landmark
    end
    
    specify "works (json)" do
      put :update, {
        :format => 'json',
        :id => @landmark.id,
        :landmark => {
          :name => 'Much Better Name'
        }
      }
      
      json['status'].should.equal 'success'
      @landmark.reload.name.should.equal 'Much Better Name'
    end
    
    specify "handles errors gracefully (json)" do
      put :update, {
        :format => 'json',
        :id => @landmark.id,
        :landmark => {
          :name => ''
        }
      }

      json['status'].should.equal 'failure'
      json['html'].should =~ /<form/
      assigns(:landmark).should.not.be.nil
    end
    
    specify "prevents access to other accounts (json)" do
      put :update, {
        :format => 'json',
        :id => landmarks(:aaron).id,
        :landmark => {
          :name => 'Much Better Name'
        }
      }
      
      json['status'].should.equal 'failure'
    end
    
    specify "correctly handles spaces entered in lat/long (json)" do
      put :update, {
        :format => 'json',
        :id => @landmark.id,
        :landmark => {
          :latitude => '   -86.347   ',
          :longitude => '   42.04   '
        }
      }
      
      json['status'].should.equal 'success'
    end
  end
  
  context "Removing a landmark" do
    specify "works (json)" do
      Landmark.should.differ(:count).by(-1) do
        delete :destroy, {
          :format => 'json',
          :id => @landmark.id
        }
      end
      
      json['status'].should.equal 'success'
    end
    
    specify "prevents access to other accounts" do
      Landmark.should.differ(:count).by(0) do
        delete :destroy, {
          :format => 'json',
          :id => landmarks(:aaron).id
        }
      end
      
      json['status'].should.equal 'failure'
    end
  end
end
