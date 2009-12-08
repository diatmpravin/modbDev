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

end
