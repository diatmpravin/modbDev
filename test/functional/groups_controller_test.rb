require 'test_helper'

describe "GroupsController", ActionController::TestCase do
  use_controller GroupsController

  setup do
    login_as :quentin
  end

  context "Index" do

    specify "show list of device groups, alphabetical order" do
      get :index
      template.should.equal "index"

      assigns(:groups).should.equal [ groups(:north), groups(:south) ]
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

  end

  context "Destroy" do

    specify "can remove a group" do

    end

  end

end
