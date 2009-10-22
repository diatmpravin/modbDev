require 'test_helper'

describe "Devices Controller", ActionController::TestCase do
  use_controller DevicesController
  
  setup do
    login_as :quentin
    @account = accounts(:quentin)
  end
  
  context "Viewing devices" do
    specify "works" do
      get :index
      
      template.should.be 'index'
      assigns(:devices).length.should.be 1
      assigns(:devices).first.should.equal devices(:quentin_device)

      assigns(:device).should.not.be.nil
    end
    
    specify "has a json view" do
      get :index, {
        :format => 'json'
      }
      
      json.length.should.be 1
      json[0]['device']['id'].should.equal devices(:quentin_device).id
      json[0]['device']['position'].should.not.be.nil    # included method
      json[0]['device']['color'].should.not.be.nil       # included method
    end
  end
  
  context "Viewing a device" do
    setup do
      @device = devices(:quentin_device)
    end
    
    specify "works" do
      get :show, {
        :id => @device.id
      }
      
      template.should.be 'show'
      assigns(:device).should.equal @device
    end
    
    specify "has a json view" do
      get :show, {
        :id => @device.id,
        :format => 'json'
      }
      
      json.length.should.be 1
      json[0]['device']['id'].should.equal @device.id
    end
  end
  
  context "Adding devices" do
    setup do
      Tracker.create(:imei_number => '923456789012345')
    end
    
    specify "works" do
      Device.should.differ(:count).by(1) do
        xhr :post, :create, {
          :name => 'Mine',
          :imei => '923456789012345',
          :imei_confirmation => '923456789012345'
        }
      end
      
      json['status'].should.equal 'success'
      device = @account.devices.last
      device.name.should.equal 'Mine'
      device.imei_number.should.equal '923456789012345'
    end
    
    specify "handles mismatch imei numbers" do
      Device.should.differ(:count).by(0) do
        xhr :post, :create, {
          :name => 'Mine',
          :imei => '923456789012345',
          :imei_confirmation => 'NOT IT!'
        }
      end
      
      json['status'].should.equal 'failure'
      json['error'].should =~ /do not match/
    end

    specify "handle unknown imei number" do
      Device.should.differ(:count).by(0) do
        xhr :post, :create, {
          :name => 'Mine',
          :imei => '1234',
          :imei_confirmation => '1234'
        }
      end
      
      json['status'].should.equal 'failure'
      json['error'].should =~ /unknown tracker/i
    end
    
    specify "handle generic device errors" do
      Device.should.differ(:count).by(0) do
        xhr :post, :create, {
          :imei => '923456789012345',
          :imei_confirmation => '923456789012345'
        }
      end
      
      json['status'].should.equal 'failure'
      json['error'].should.include("Name can't be blank")
    end
  end
  
  context "Editing devices" do
    setup do
      @device = devices(:quentin_device)
    end
    
    specify "displays edit page" do
      get :edit, {
        :id => @device.id
      }
      
      template.should.be 'edit'
      assigns(:device).id.should.equal @device.id
    end
    
    specify "works" do
      Tracker.create(:imei_number => '101010010101019')
      
      post :update, {
        :id => @device.id,
        :device => {
          @device.id.to_s => {
            :name => 'A new name',
            :imei_number => '101010010101019'
          }
        }
      }
      
      json['status'].should.equal 'success'
      @device.reload
      @device.name.should.equal 'A new name'
      @device.imei_number.should.equal '101010010101019'
    end
    
    specify "handles user errors" do
      post :update, {
        :id => @device.id,
        :device => {
          @device.id.to_s => {
            :name => "I'm a name that's 31 characters"
          }
        }
      }
      
      json['status'].should.equal 'failure'
      json['html'].should =~ /is too long/
      assigns(:device).name.should.equal "I'm a name that's 31 characters"
      assigns(:device).errors.on(:name).should.equal "is too long (maximum is 30 characters)"
    end
  end
  
  context "Destroying devices" do
    setup do
      @device = devices(:quentin_device)
    end

    specify "destroy works" do
      Device.should.differ(:count).by(-1) do
        post :destroy, {
          :id => @device.id
        }
      end
      
      json['status'].should.equal 'success'
      @account.reload.devices.should.be.empty
    end
  end
  
  context "Getting device's current position" do
    setup do
      @device = devices(:quentin_device)
      @point = points(:quentin_point2)
    end
    
    specify "works" do
      get :position, {
        :id => @device.id,
        :format => 'json'
      }
      
      position = ActiveSupport::JSON.decode(body)
      position['point']['device_id'].should.equal @device.id
      position['point']['speed'].should.equal @point.speed
    end
  end
end
