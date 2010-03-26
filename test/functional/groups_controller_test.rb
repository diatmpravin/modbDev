require 'test_helper'

describe "GroupsController", ActionController::TestCase do

  setup do
    use_controller GroupsController
    login_as :quentin
    Tracker.any_instance.stubs(:async_configure)
    
    @group = device_groups(:north)
  end

  context "Index" do

    specify "show list of device groups, alphabetical order" do
      get :index
      template.should.equal "index"

      assigns(:groups).should.equal [ device_groups(:north), device_groups(:south) ]
    end

    specify "handles pagination" do
      g = device_groups(:north)
      50.times { g.clone.save}

      get :index
      template.should.be 'index'

      assigns(:groups).length.should.equal 30

      get :index, :page => 2
      template.should.be 'index'

      assigns(:groups).length.should.equal 22
    end

    specify "takes into account Group filter parameters" do
      set_filter Device, "get_vehicle"
      set_filter DeviceGroup, "get_groupin"

      DeviceGroup.expects(:search).with(
        "get_groupin", :conditions => {},
        :page => nil, :per_page => 30,
        :with => {:account_id => accounts(:quentin).id},
        :mode => :extended
      ).returns(accounts(:quentin).device_groups)

      get :index
      template.should.be 'index'
    end

  end

  context "Show" do

    setup do
      @group = device_groups(:north)
    end

    specify "shows vehicles in the group" do
      @group.devices << devices(:quentin_device)

      xhr :get, :show, :id => device_groups(:north).id
      template.should.be "show"

      assigns(:group).should.equal device_groups(:north)
      assigns(:devices).should.equal [devices(:quentin_device)]
    end

  end

  context "Creating a device group" do
    specify "shows the new group form" do
      get :new
      template.should.equal "new"

      assigns(:group).should.not.be.nil
    end
    
    specify "can create a new device group (json)" do
      post :create, :device_group => {:name => "New Groupzor"}
      
      json['status'].should.equal 'success'
      json['html'].should =~ /New Groupzor/

      g = accounts(:quentin).device_groups.first
      g.name.should.equal "New Groupzor"
    end
  end

  context "Editing a device group" do
    specify "shows the edit group form" do
      get :edit, :id => @group.id
      template.should.equal "edit"

      assigns(:group).should.equal @group
    end

    specify "can update a group" do
      put :update, :id => @group.id, :device_group => {:name => "Oh yeah"}
      
      json['status'].should.equal 'success'
      json['html'].should =~ /Oh yeah/

      @group.reload
      @group.name.should.equal "Oh yeah"
    end

    specify "cannot edit a group this account doesn't own" do
      g = accounts(:aaron).device_groups.create :name => "Aaron"

      put :update, :id => g.id, :device_group => {:name => "Bad"}
      
      #json['status'].should.equal 'failure'
      should.redirect_to device_groups_path

      g.reload
      g.name.should.not.equal "Bad"
    end
  end

  context "Destroying a device group" do
    specify "can remove a group" do
      @group = device_groups(:north)
      delete :destroy, :id => @group.id
      
      json['status'].should.equal 'success'
      json['html'].should.not.be.nil

      assert !DeviceGroup.exists?(@group.id)
    end
  end

  context "Live Look" do
    setup do
      @group = device_groups(:north)
    end

    specify "gather up device ids for this group and forward to live look" do
      d = devices(:quentin_device)
      d2 = Device.generate!
      
      # Note: devices now ordered by name in group, so order is [d2, d]
      @group.devices << d
      @group.devices << d2

      get :live_look, :id => @group.id
      should.redirect_to live_look_devices_path(:device_ids => "#{d2.id},#{d.id}")
    end

    specify "if group is empty, redirect w/ message" do
      get :live_look, :id => @group.id
      should.redirect_to device_groups_path

      flash[:warning].should.not.be.nil
    end

  end

end
