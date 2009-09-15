require 'test_helper'

describe "Reports Controller", ActionController::TestCase do
  use_controller ReportsController
  
  setup do
    login_as :quentin
    @account = accounts(:quentin)
  end
  
  context "Viewing reports page" do
    specify "works" do
      get :index
      
      template.should.be 'index'
    end
  end
  
end
