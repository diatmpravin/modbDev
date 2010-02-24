require File.dirname(__FILE__) + '/../../test_helper'

context "Import::VehiclesController", ActionController::TestCase do
  use_controller Import::VehiclesController

  context "Main Page" do

    setup do
      @user = users(:quentin)
      login_as :quentin
    end

    specify "shows upload form" do
      get :index
      template.should.be "index"
    end

    specify "requires fleet access" do
      @user.update_attributes(:roles => [User::Role::USERS])

      get :index
      should.redirect_to root_path
    end

  end

  context "Uploading file" do

    context "Allows certain types" do

      xspecify "allows xls"

      xspecify "allows csv"

      xspecify "allows ods" 

      xspecify "errors out if file type not recognized"

    end

    context "Processes file" do

    end

  end
end
