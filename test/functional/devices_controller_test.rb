require 'test_helper'

describe "Devices Controller", ActionController::TestCase do
  use_controller DevicesController
  
  setup do
    users(:quentin).update_attributes(:roles => [User::Role::FLEET])
    login_as :quentin
    @account = accounts(:quentin)
    Tracker.any_instance.stubs(:async_configure)
  end
  
  context "Viewing devices" do
    specify "works" do
      get :index
      
      template.should.be 'index'
      assigns(:devices).length.should.be 1
      assigns(:devices).first.should.equal devices(:quentin_device)

      assigns(:device).should.not.be.nil
    end

    specify "handles paging" do
      get :index, :page => 2
      
      template.should.be 'index'
      assigns(:devices).length.should.be 0
      assigns(:device).should.not.be.nil
    end
    
    specify "xhr: renders new table view if page given" do
      xhr :get, :index, :page => 2
      
      template.should.be '_list'
      assigns(:devices).length.should.be 0
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

    specify "Takes into account Device filter parameters" do
      set_filter Device, "get_vehicle"
      set_filter Geofence, "go_geo"

      Device.expects(:search).with(
        "get_vehicle", :conditions => {}, 
        :page => nil, :per_page => 30,
        :with => {:account_id => accounts(:quentin).id}, 
        :mode => :extended
      ).returns(accounts(:quentin).devices)

      get :index
      template.should.be 'index'
    end

    specify "Search doesn't die if sphinx isn't running" do
      set_filter Device, "testing"

      Device.expects(:search).raises(RuntimeError.new("Oh noes!"))
      Mailer.expects(:deliver_exception_thrown)

      get :index
      template.should.be 'index'

      flash[:warning].should.match(/filtering is currently unavailable/i)
      assigns(:devices).length.should.be 1
      assigns(:devices).first.should.equal devices(:quentin_device)
    end
  end
  
  context "Viewing a device" do
    setup do
      @device = devices(:quentin_device)
    end
    
    specify "works (shows you the edit form)" do
      get :show, {
        :id => @device.id
      }
      
      template.should.be 'edit'
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
      Tracker.create(:imei_number => '923456789012345', :account => @account)
    end
    
    specify "works" do
      Device.should.differ(:count).by(1) do
        post :create, {
          :device => {
            :name => 'Mine',
            :imei_number => '923456789012345'
          }
        }
      end
      
      device = @account.devices.last
      device.name.should.equal 'Mine'
      device.imei_number.should.equal '923456789012345'
    end
    
    specify "fail on unknown imei number" do
      Device.should.differ(:count).by(0) do
        post :create, {
          :device => {
            :name => 'Mine',
            :imei_number => '1234'
          }
        }
      end
    end

    specify "fail on previously assigned imei number" do
      Device.should.differ(:count).by(0) do
        post :create, {
          :device => {
            :name => 'Mine',
            :imei_number => '123456789012345'
          }
        }
      end
    end
    
    specify "handle generic device errors" do
      Device.should.differ(:count).by(0) do
        post :create, {
          :device => { :imei_number => '923456789012345' }
        }
      end
      
      assigns(:device).errors.on(:name).should.match "can't be blank"
    end
    
    specify "requires FLEET role" do
      users(:quentin).update_attributes(:roles => [])
      login_as :quentin
      
      Device.should.differ(:count).by(0) do
        xhr :post, :create, {
          :name => 'Mine',
          :imei => '923456789012345',
          :imei_confirmation => '923456789012345'
        }
      end
      
      should.redirect_to root_path
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
      post :update, {
        :id => @device.id,
        :device => {
          :name => 'Updated name',
          :rpm_threshold => 3017
        }
      }
      
      should.redirect_to :action => 'index'
      @device.reload
      @device.name.should.equal 'Updated name'
      @device.rpm_threshold.should.equal 3017
    end
    
    specify "handles user errors" do
      post :update, {
        :id => @device.id,
        :device => {
           :name => "I'm a name that's 31 characters"
        }
      }
      
      template.should.equal 'edit'
      assigns(:device).name.should.equal "I'm a name that's 31 characters"
      assigns(:device).errors.on(:name).should.equal "is too long (maximum is 30 characters)"
    end
    
    specify "requires FLEET role" do
      users(:quentin).update_attributes(:roles => [])
      login_as :quentin
      
      post :update, {
        :id => @device.id,
        :device => {
          @device.id.to_s => {
            :name => 'Updated name',
            :rpm_threshold => 3017
          }
        }
      }
      
      should.redirect_to root_path
    end
    
    specify "requires access to the device" do
      users(:quentin).update_attributes(:device_group => groups(:north))
      login_as :quentin
      
      post :update, {
        :id => @device.id,
        :device => {
          @device.id.to_s => {
            :name => 'Updated name',
            :rpm_threshold => 3017
          }
        }
      }
      
      should.redirect_to root_path
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
      
      should.redirect_to :action => 'index'
      @account.reload.devices.should.be.empty
    end

    specify "requires FLEET role" do
      users(:quentin).update_attributes(:roles => [])
      login_as :quentin
    
      Device.should.differ(:count).by(0) do
        post :destroy, {
          :id => @device.id
        }
      end
      
      should.redirect_to root_path
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

  context "Applying a profile to devices" do
    setup do
      @device = devices(:quentin_device)
      @profile = device_profiles(:quentin)
    end

    specify "applies a profile and immediately updates settings" do
      @device.update_attributes(:alert_on_speed => false, :device_profile_id => nil)

      post :apply_profile, {
        :apply_ids => @device.id.to_s,
        :profile_id => @profile.id.to_s
      }

      should.redirect_to devices_path

      @device.reload
      @device.device_profile.should.equal @profile
      @device.alert_on_speed.should.equal true
    end

    specify "will clear the profile if no profile id specified" do
      post :apply_profile, {
        :apply_ids => @device.id.to_s
      }

      @device.reload
      @device.device_profile.should.equal nil
    end
  end

  context "Applying a group to devices" do
    setup do
      @device = devices(:quentin_device)
      @group = groups(:north)
    end

    specify "adds the list of vehicles to the group" do
      post :apply_group, {
        :apply_ids => @device.id.to_s,
        :group_id => @group.id.to_s,
        :group_name => ""
      }
      should.redirect_to devices_path

      @device.reload
      @device.groups.should.equal [@group]
    end

    specify "doesn't add vehicles to a group multiple times" do
      d2 = Device.generate!
      3.times do
        post :apply_group, {
          :apply_ids => [@device.id, d2.id].join(","),
          :group_id => @group.id.to_s,
          :group_name => ""
        }
      end

      @group.reload
      @group.devices.should.equal [@device, d2]
    end
    
    specify "can specify a name and create a new group" do
      d1 = Device.generate!
      d2 = Device.generate!
      d3 = Device.generate!

      Group.should.differ(:count).by(1) do
        post :apply_group, {
          :apply_ids => [@device.id, d1.id, d2.id, d3.id].join(","),
          :group_id => @group.id.to_s,
          :group_name => "Testr"
        }
      end

      g = d1.reload.groups[0]

      g.name.should.equal "Testr"
      g.of.should.equal "Device"
      g.devices.should.equal [@device, d1, d2, d3]

      @group.devices.should.equal []
    end

    specify "doesn't re-add if device already in group" do
      d1 = Device.generate!
      d2 = Device.generate!
      d3 = Device.generate!

      @group.devices << @device
      @group.save; @group.reload

      post :apply_group, {
        :apply_ids => [@device.id, d1.id, d2.id, d3.id].join(","),
        :group_id => @group.id.to_s,
        :group_name => ""
      }

      @group.reload; @device.reload
      @group.devices.length.should.equal 4
      @group.devices.should.equal [@device, d1, d2, d3]

      @device.groups.should.equal [@group]
    end
  end

  context "Removing vehicles from a group" do
    setup do
      @device = devices(:quentin_device)
      @group = groups(:north)
      @group.devices << @device
      @group.reload
    end

    specify "removes vehicles from the given group" do
      post :remove_group, {
        :apply_ids => @device.id.to_s,
        :group_id => @group.id.to_s
      }
      should.redirect_to devices_path

      @device.reload
      @device.groups.should.equal []
    end

    specify "doesn't care of a vehicle isn't in the given group" do
      d1 = Device.generate!
      d2 = Device.generate!
      d3 = Device.generate!

      @group.devices << @device
      @group.devices << d1
      @group.save; @group.reload

      post :remove_group, {
        :apply_ids => [@device.id, d1.id, d2.id, d3.id].join(","),
        :group_id => @group.id.to_s
      }

      @group.reload; @device.reload
      @group.devices.should.equal []
      @device.groups.should.equal []
    end
  end

  context "Live Look" do

    setup do
      @d1 = Device.generate!
      @d2 = Device.generate!
      @d3 = Device.generate!
    end

    specify "can take a list of devices and show them on a live look map" do
      get :live_look, :device_ids => [@d1.id, @d2.id, @d3.id].join(",")
      template.should.be "live_look"

      assigns(:devices).should.equal [@d1, @d2, @d3]
    end

    specify "json request returns device information for the given devices" do
      get :live_look, :device_ids => [@d1.id, @d2.id, @d3.id].join(","),
        :format => 'json'

      json.length.should.equal 3
      json[0]['device']['id'].should.equal @d1.id
    end

    specify "return to list of no devices selected to view" do
      get :live_look, :device_ids => ""
      should.redirect_to devices_path
    end

  end
end
