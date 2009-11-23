require 'test_helper'

describe "Tags Controller", ActionController::TestCase do
  use_controller TagsController
  
  setup do
    login_as :quentin
    @account = accounts(:quentin)
  end
  
  context "Tag List" do
    specify "works" do
      get :index, {:q => 'P'}
      
      json.should.equal ['Personal']
    end
  end
end
