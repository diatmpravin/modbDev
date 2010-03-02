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
    specify "works in html" do
      get :index
      
      template.should.equal 'index'
      assigns(:landmarks).should.include landmarks(:quentin)
    end
  end
  
  context "Creating a landmark" do
    specify "displays the new landmark form" do
      get :new
      
      template.should.equal 'new'
      assigns(:landmark).should.not.be.nil
    end
    
    specify "works" do
      Landmark.should.differ(:count).by(1) do
        post :create, {
          :landmark => 
            {
              :name => 'My Landmark',
              :latitude => '39.267',
              :longitude => '-86.9074'
            }
        }
      end

      should.redirect_to landmarks_path
      
      @account.reload.landmarks.length.should.equal 2
      @account.landmarks.last.latitude.should.equal BigDecimal.new('39.267')
      @account.landmarks.last.longitude.should.equal BigDecimal.new('-86.9074')
    end
    
    specify "handles errors gracefully" do
      post :create, {
        :landmark => 
          {
            :latitude => '39.267',
            :longitude => '-86.9074'
          }
      }

      template.should.equal "new"
      assigns(:landmark).should.not.be.nil
    end
    
    specify "correctly handles spaces entered in lat/long" do
      post :create, {
        :id => @landmark.id,
        :landmark => 
          {
            :name => 'Test',
            :latitude => '   -86.347   ',
            :longitude => '   42.04   '
          }
      }

      should.redirect_to landmarks_path
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
    
    specify "works" do
      put :update, {
        :id => @landmark.id,
        :landmark => {
          :name => 'Much Better Name'
        }
      }
      
      should.redirect_to landmarks_path
      @landmark.reload.name.should.equal 'Much Better Name'
    end
    
    specify "handles errors gracefully" do
      put :update, {
        :id => @landmark.id,
        :landmark => {
          :name => ''
        }
      }

      template.should.equal "edit"
      assigns(:landmark).should.not.be.nil
    end
    
    specify "prevents access to other accounts" do
      put :update, {
        :id => landmarks(:aaron).id,
        :landmark => {
          :name => 'Much Better Name'
        }
      }

      should.redirect_to :action => "index"
    end
    
    specify "correctly handles spaces entered in lat/long" do
      put :update, {
        :id => @landmark.id,
        :landmark => {
          :latitude => '   -86.347   ',
          :longitude => '   42.04   '
        }
      }
      
      should.redirect_to landmarks_path
    end
  end
  
  context "Removing a landmark" do
    specify "works" do
      Landmark.should.differ(:count).by(-1) do
        delete :destroy, {
          :id => @landmark.id
        }
      end
      
      should.redirect_to landmarks_path
    end
    
    specify "prevents access to other accounts" do
      Landmark.should.differ(:count).by(0) do
        delete :destroy, {
          :id => landmarks(:aaron).id
        }
      end
    end
  end
end
