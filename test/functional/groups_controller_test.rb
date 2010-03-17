require 'test_helper'

describe "GroupsController", ActionController::TestCase do

  setup do
    use_controller GroupsController
    login_as :quentin
    Tracker.any_instance.stubs(:async_configure)
  end

  context "Index" do

    specify "show list of device groups, alphabetical order" do
      get :index
      template.should.equal "index"

      assigns(:groups).should.equal [ groups(:north), groups(:south) ]
    end

    specify "handles pagination" do
      g = groups(:north)
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
      set_filter Group, "get_groupin"

      Group.expects(:search).with(
        "get_groupin", :conditions => {},
        :page => nil, :per_page => 30,
        :with => {:account_id => accounts(:quentin).id},
        :mode => :extended
      ).returns(accounts(:quentin).groups)

      get :index
      template.should.be 'index'
    end

  end

  context "Show" do

    setup do
      @group = groups(:north)
    end

    specify "shows vehicles in the group" do
      @group.devices << devices(:quentin_device)

      xhr :get, :show, :id => groups(:north).id
      template.should.be "show"

      assigns(:group).should.equal groups(:north)
      assigns(:devices).should.equal [devices(:quentin_device)]
    end

  end

  context "New" do

    specify "show the form" do
      get :new
      template.should.equal "new"

      assigns(:group).should.not.be.nil
    end

  end

  context "Create" do

    specify "build a new device group" do
      post :create, :group => {:name => "New Groupzor"}
      should.redirect_to groups_path

      g = accounts(:quentin).groups.first
      g.name.should.equal "New Groupzor"
      g.of.should.equal "Device"
    end

  end

  context "Edit" do
    setup do
      @group = groups(:north)
    end

    specify "shows the form" do
      get :edit, :id => @group.id
      template.should.equal "edit"

      assigns(:group).should.equal @group
    end

  end

  context "Update" do
    setup do
      @group = groups(:north)
    end

    specify "updates a group" do
      put :update, :id => @group.id, :group => {:name => "Oh yeah"}
      should.redirect_to groups_path

      @group.reload
      @group.name.should.equal "Oh yeah"
    end

    specify "cannot edit a group account doesn't own" do
      g = accounts(:aaron).groups.create :name => "Aaron"

      put :update, :id => g.id, :group => {:name => "Bad"}
      should.redirect_to groups_path

      g.reload
      g.name.should.not.equal "Bad"
    end

  end

  context "Destroy" do
    setup do
      @group = groups(:north)
    end

    specify "can remove a group" do
      delete :destroy, :id => @group.id
      should.redirect_to groups_path

      assert !Group.exists?(@group.id)
    end

  end

  context "Live Look" do
    setup do
      @group = groups(:north)
    end

    specify "gather up device ids for this group and forward to live look" do
      d = devices(:quentin_device)
      d2 = Device.generate!
      @group.devices << d
      @group.devices << d2

      get :live_look, :id => @group.id
      should.redirect_to live_look_devices_path(:device_ids => "#{d.id},#{d2.id}")
    end

    specify "if group is empty, redirect w/ message" do
      get :live_look, :id => @group.id
      should.redirect_to groups_path

      flash[:warning].should.not.be.nil
    end

  end

end
