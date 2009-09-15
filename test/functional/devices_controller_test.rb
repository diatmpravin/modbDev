require 'test_helper'

describe "Devices Controller", ActionController::TestCase do
  use_controller DevicesController
  
  setup do
    login_as :quentin
    @account = accounts(:quentin)
  end
  
  context "Viewing devices" do
    specify "works" do
      @account.subscription.update_attribute(:next_bill_date, Date.today)

      get :index
      
      template.should.be 'index'
      assigns(:devices).length.should.be 1
      assigns(:devices).first.should.equal devices(:quentin_device)
      assigns(:subscription).should.equal @account.subscription

      assigns(:device).should.not.be.nil
    end

    specify "requires working subscription (cancelled)" do
      @account.subscription.update_attribute(:status, "cancelled")
      get :index
      should.redirect_to edit_account_path
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
      Subscription.any_instance.expects(:charge_proration).returns(true)
      
      Device.should.differ(:count).by(1) do
        xhr :post, :create, {
            :imei => '923456789012345',
            :imei_confirmation => '923456789012345'
        }
      end
      
      json['status'].should.equal 'success'
      device = @account.devices.last
      device.imei_number.should.equal '923456789012345'
    end
    
    specify "handles mismatch imei numbers" do
      Device.should.differ(:count).by(0) do
        xhr :post, :create, {
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
            :imei => '1234',
            :imei_confirmation => '1234'
        }
      end
      
      json['status'].should.equal 'failure'
      json['error'].should =~ /unknown tracker/i
    end

    specify "handles payment errors" do
      Subscription.any_instance.expects(:charge_proration).returns(false)

      Device.should.differ(:count).by(0) do
        xhr :post, :create, {
            :imei => '923456789012345',
            :imei_confirmation => '923456789012345'
        }
      end
      
      json['status'].should.equal 'failure'
      json['error'].should =~ /Error charging your/i
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

    specify "uses :update to undelete a device" do
      @device.mark_for_deletion

      put :update, {:id => @device.id, :undelete => true}
      status.should.be :success
      template.should.be nil

      @device.reload
      @device.to_be_deleted?.should.be false
    end
  end
  
  context "Destroying devices" do
    setup do
      @device = devices(:quentin_device)
      @sub = subscriptions(:quentin)
      @sub.update_attribute(:next_bill_date, Date.parse("01/02/2009"))
    end

    specify "mark to be deleted at next bill date" do
      Device.should.differ(:count).by(0) do
        post :destroy, {
          :id => @device.id
        }
      end

      @device.reload
      @device.to_be_deleted.should.be true

      json['status'].should.equal 'mark'
      json['delete_at'].should.equal "January 02, 2009"
    end

    specify "flat removes the tracker when user is in setup wizard" do
      accounts(:quentin).update_attribute(:setup_status, 1)
      
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
