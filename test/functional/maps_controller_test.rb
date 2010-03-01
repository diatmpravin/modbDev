require 'test_helper'

describe "Maps Controller", ActionController::TestCase do
  use_controller MapsController
  
  setup do
    login_as :quentin
    @account = accounts(:quentin)
  end
  
  context "Main maps page" do
    specify "works" do
      get :index
      
      template.should.be 'index'
      assigns(:devices).should.equal @account.devices
    end
    
    specify "defaults the device if there is only one" do
      get :index
      
      template.should.be 'index'
      assigns(:device).should.equal devices(:quentin_device)
    end
    
    specify "will use a specific device if device_id is sent" do
      d = @account.devices.new(:name => 'New')
      d.tracker = Tracker.create(:imei_number => '171727273737471', :account => @account)
      d.save
      
      get :index, { :device_id => d.id }
      
      template.should.be 'index'
      assigns(:devices).length.should.be 2
      assigns(:device).should.equal d
    end
    
    specify "will default to 'All Vehicles' if no device_id is sent" do
      d = @account.devices.new(:name => 'New')
      d.tracker = Tracker.create(:imei_number => '171727273737471', :account => @account)
      d.save
      
      get :index
      
      template.should.be 'index'
      assigns(:devices).length.should.be 2
      assigns(:device).should.be.nil
    end
  end
  
  context "Current Status" do
    specify "works" do
      get :status
      
      assigns(:devices).should.equal @account.devices
    end
    
    specify "will use a specific device if device_id is sent" do
      d = @account.devices.new(:name => 'New')
      d.tracker = Tracker.create(:imei_number => '171727273737471', :account => @account)
      d.save
      
      get :status, { :device_id => d.id }
      
      assigns(:devices).length.should.be 1
      assigns(:devices).first.should.equal d
    end
  end
end
