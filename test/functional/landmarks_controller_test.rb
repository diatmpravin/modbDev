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
    
    specify "works in json" do
      get :index, {
        :format => 'json'
      }
      
      json[0]['landmark']['id'].should.equal @landmark.id
      json[0]['landmark']['name'].should.equal @landmark.name
      json[0]['landmark']['latitude'].should.equal @landmark.latitude.to_f
      json[0]['landmark']['longitude'].should.equal @landmark.longitude.to_f
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
    
    specify "correctly handles spaces entered in lat/long" do
      post :create, {
        :id => @landmark.id,
        :landmark => [
          {
            :name => 'Test',
            :latitude => '   -86.347   ',
            :longitude => '   42.04   '
          }
        ]
      }
      
      json['status'].should.equal 'success'
      json['edit'].should =~ /value="-86.34700"/
      json['edit'].should =~ /value="42.04000"/
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
    
    specify "prevents access to other accounts" do
      should.raise(ActiveRecord::RecordNotFound) do
        put :update, {
          :id => landmarks(:aaron).id,
          :landmark => {
            @landmark.id.to_s => {
              :name => 'Much Better Name'
            }
          }
        }
      end
    end
    
    specify "correctly handles spaces entered in lat/long" do
      put :update, {
        :id => @landmark.id,
        :landmark => {
          @landmark.id.to_s => {
            :latitude => '   -86.347   ',
            :longitude => '   42.04   '
          }
        }
      }
      
      json['status'].should.equal 'success'
      json['edit'].should =~ /value="-86.34700"/
      json['edit'].should =~ /value="42.04000"/
    end
  end
  
  context "Removing a landmark" do
    specify "works" do
      Landmark.should.differ(:count).by(-1) do
        delete :destroy, {
          :id => @landmark.id
        }
      end
      
      json['status'].should.equal 'success'
    end
    
    specify "prevents access to other accounts" do
      Landmark.should.differ(:count).by(0) do
        should.raise(ActiveRecord::RecordNotFound) do
          delete :destroy, {
            :id => landmarks(:aaron).id
          }
        end
      end
    end
  end
end
