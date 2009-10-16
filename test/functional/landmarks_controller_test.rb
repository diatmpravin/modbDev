require 'test_helper'

describe "Landmarks Controller", ActionController::TestCase do
  use_controller LandmarksController
  
  setup do
    login_as :quentin
    @account = accounts(:quentin)
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
          :landmark => {
            :name => 'My Landmark',
            :latitude => '39.267',
            :longitude => '-86.9074'
          },
          :format => 'json'
        }
        
        json['status'].should.equal 'success'
        json['view'].should =~ /<h2>My Landmark<\/h2>/
        
        @account.reload.landmarks.length.should.equal 2
        @account.landmarks.last.latitude.should.equal BigDecimal.new('39.267')
        @account.landmarks.last.longitude.should.equal BigDecimal.new('-86.9074')
      end
    end
    
    specify "handles errors gracefully" do
      post :create, {
        :landmark => {
          :latitude => '39.267',
          :longitude => '-86.9074'
        },
        :format => 'json'
      }
      
      json['status'].should.equal 'failure'
      json['html'].should =~ /can't be blank/
    end
  end
  
end
