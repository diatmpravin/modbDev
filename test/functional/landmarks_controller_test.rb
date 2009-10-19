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
    specify "works" do
      get :index
      
      template.should.equal 'index'
      assigns(:landmarks).should.include landmarks(:quentin)
    end
  end
  
  context "Creating a landmark" do
    specify "displays the new landmark form" do
      get :new
      
      template.should.equal 'new'
      assigns(:landmark).account.should.equal @account
    end
    
    specify "works" do
      Landmark.should.differ(:count).by(1) do
        post :create, {
          :landmark => [
            {
              :name => 'My Landmark',
              :latitude => '39.267',
              :longitude => '-86.9074'
            }
          ],
          :format => 'json'
        }
        
        json['status'].should.equal 'success'
        json['view'].should =~ /<h2>My Landmark<\/h2>/
        json['edit'].should =~ /value="My Landmark"/
        
        @account.reload.landmarks.length.should.equal 2
        @account.landmarks.last.latitude.should.equal BigDecimal.new('39.267')
        @account.landmarks.last.longitude.should.equal BigDecimal.new('-86.9074')
      end
    end
    
    specify "handles errors gracefully" do
      post :create, {
        :landmark => [
          {
            :latitude => '39.267',
            :longitude => '-86.9074'
          }
        ],
        :format => 'json'
      }
      
      json['status'].should.equal 'failure'
      json['html'].should =~ /can't be blank/
    end
  end
  
  context "Viewing and editing a landmark" do
    specify "displays a landmark" do
      get :show, {
        :id => @landmark.id
      }
      
      template.should.equal 'show'
      assigns(:landmark).should.equal @landmark
    end
    
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
          @landmark.id.to_s => {
            :name => 'Much Better Name'
          }
        }
      }
      
      json['status'].should.equal 'success'
      json['view'].should =~ /<h2>Much Better Name<\/h2>/
      json['edit'].should =~ /value="Much Better Name"/
      
      @landmark.reload.name.should.equal 'Much Better Name'
    end
    
    specify "handles errors gracefully" do
      put :update, {
        :id => @landmark.id,
        :landmark => {
          @landmark.id.to_s => {
            :name => ''
          }
        }
      }
      
      json['status'].should.equal 'failure'
      json['html'].should =~ /can't be blank/
    end
  end
end
