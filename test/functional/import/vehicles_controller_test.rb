require File.dirname(__FILE__) + '/../../test_helper'

context "Import::VehiclesController", ActionController::TestCase do
  use_controller Import::VehiclesController

  setup do
    @user = users(:quentin)
    login_as :quentin
  end

  context "Main Page" do

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

      specify "shows preview page if valid" do
        file = fixture_file_upload("import/proper_10.csv", "text/csv")

        post :create, :upload => file
        template.should.be "create"

        assigns(:parser).should.not.be.nil
        assigns(:processor).should.not.be.nil
        assigns(:processor).file_name.should.equal "proper_10.csv"
      end

      specify "errors should show upload page again" do
        file = fixture_file_upload("import/proper_10.xls", "text/csv")

        post :create, :upload => file
        template.should.be "index"

        assigns(:parser).should.not.be.nil
        flash[:error].should.match /Unable to parse/
      end

    end

  end
end
