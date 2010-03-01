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

    context "Processes file" do

      specify "shows preview page if valid" do
        file = fixture_file_upload("import/proper_10.csv", "text/csv")

        Import::VehicleImporter.any_instance.expects(:store).with { |file, data|
          file =="proper_10.csv" &&
            data.length == 10
        }

        post :create, :upload => file
        template.should.be "create"

        assigns(:parser).should.not.be.nil
        assigns(:processor).should.not.be.nil
      end

      specify "errors should show upload page again" do
        file = fixture_file_upload("import/proper_10.xls", "text/csv")

        post :create, :upload => file
        template.should.be "index"

        assigns(:parser).should.not.be.nil
        flash[:error].should.match /Unable to parse/
      end

    end

    context "Processing vehicles list" do

      specify "creates vehicles accordingly" do
        Import::VehicleImporter.any_instance.expects(:process).with("proper_10.csv").returns(true)

        put :update, :id => "huh", :file_name => "proper_10.csv"
        template.should.be "update"

        assigns(:processor).should.not.be.nil
      end

    end

  end
end
