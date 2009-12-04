require 'test_helper'

describe "Trackers Controller", ActionController::TestCase do
  use_controller TrackersController
  
  setup do
    login_as :quentin
    @account = accounts(:quentin)
    @tracker = trackers(:quentin_tracker)
  end
  
  context "Viewing trackers" do
    specify "works" do
      get :index
      
      template.should.be 'index'
      assigns(:trackers).length.should.be 2
    end
  end
  
  context "Creating trackers" do
    specify "displays a new form" do
      get :new
      
      template.should.be 'new'
      assigns(:tracker).should.not.be.nil
    end
    
    specify "works" do
      Tracker.should.differ(:count).by(1) do
        post :create, {
          :tracker => {
            :imei_number => '123451234554321',
            :sim_number => '10101010101020202020'
          }
        }
      end
      
      should.redirect_to :action => 'index'
    end
    
    specify "handles errors gracefully" do
      Tracker.should.differ(:count).by(0) do
        post :create, {
          :tracker => {
            :imei_number => '1234512345',
            :sim_number => '10101010101020202020'
          }
        }
      end
      
      template.should.be 'new'
      assigns(:tracker).errors.on(:imei_number).should.equal 'must be 15 digits'
    end
  end
  
  context "Editing trackers" do
    specify "displays an edit form" do
      get :edit, {
        :id => @tracker.id
      }
      
      template.should.be 'edit'
      assigns(:tracker).should.equal @tracker
    end
    
    specify "works" do
      post :update, {
        :id => @tracker.id,
        :tracker => {
          :imei_number => '178923234567928'
        }
      }
      
      should.redirect_to :action => 'index'
      @tracker.reload.imei_number.should.equal '178923234567928'
    end
    
    specify "handles errors gracefully" do
      post :update, {
        :id => @tracker.id,
        :tracker => {
          :imei_number => 'abcd'
        }
      }
      
      template.should.be 'edit'
      assigns(:tracker).errors.on(:imei_number).should.equal 'must be 15 digits'
    end
  end
  
  context "Destroying trackers" do
    specify "works" do
      Tracker.should.differ(:count).by(-1) do
        post :destroy, {
          :id => @tracker.id
        }
      end
      
      should.redirect_to :action => 'index'
      Tracker.find_by_id(@tracker.id).should.be.nil
    end
  end
end
