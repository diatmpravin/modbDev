require 'test_helper'

describe "GroupsController", ActionController::TestCase do
  use_controller GroupsController
  
  setup do
    DeviceGroup.rebuild!
    
    login_as :quentin
    Tracker.any_instance.stubs(:async_configure)
    
    @group = device_groups(:north)
  end

  specify "has no index page" do
    get :index
    
    should.redirect_to report_card_path
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
    
    specify "can move a group" do
      @other = device_groups(:south)
      
      @group.parent.should.be.nil
      
      put :update, :id => @group.id, :device_group => {:parent_id => @other.id}
      
      json['status'].should.equal 'success'
      
      @group.reload.parent.should.equal @other
      @other.reload.children.should.equal [@group]
    end
    
    specify "errors gracefully if a move is invalid" do
      @other = device_groups(:south)
      @other.move_to_child_of(@group)
      
      put :update, :id => @group.id, :device_group => {:parent_id => @other.id}
      
      json['status'].should.equal 'failure'
      json['error'].should =~ /Cannot move/
    end
    
    specify "can move to root by specifying parent_id of 0" do
      @other = device_groups(:south)
      @group.move_to_child_of(@other)
      
      @group.reload.parent.should.equal @other
      
      put :update, :id => @group.id, :device_group => {:parent_id => '0'}
      
      json['status'].should.equal 'success'
      
      @group.reload.parent.should.be.nil
    end
  end

  context "Destroying a device group" do
    specify "can remove a group" do
      delete :destroy, :id => @group.id
      
      json['status'].should.equal 'success'
      json['html'].should.not.be.nil

      assert !DeviceGroup.exists?(@group.id)
    end
  end

  # context "Live Look" do
    # setup do
      # @group = device_groups(:north)
    # end

    # specify "gather up device ids for this group and forward to live look" do
      # d = devices(:quentin_device)
      # d2 = Device.generate!
      
      # # Note: devices now ordered by name in group, so order is [d2, d]
      # @group.devices << d
      # @group.devices << d2

      # get :live_look, :id => @group.id
      # should.redirect_to live_look_devices_path(:device_ids => "#{d2.id},#{d.id}")
    # end

    # specify "if group is empty, redirect w/ message" do
      # get :live_look, :id => @group.id
      # should.redirect_to device_groups_path

      # flash[:warning].should.not.be.nil
    # end
  # end
end
