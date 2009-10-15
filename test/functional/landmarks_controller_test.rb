require 'test_helper'

describe "Landmarks Controller", ActionController::TestCase do
  use_controller LandmarksController
  
  setup do
    login_as :quentin
    @account = accounts(:quentin)
    @device = devices(:quentin_device)
  end
  
  context "Landmark List" do
    specify "works" do
      get :index
      
      template.should.equal 'index'
      assigns(:landmarks).should.include landmarks(:quentin)
    end
  end
  
end
