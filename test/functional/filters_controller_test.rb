require 'test_helper'

describe "FiltersController", ActionController::TestCase do
  use_controller FiltersController

  setup do
    login_as :quentin
    @account = accounts(:quentin)
  end

  specify "can create a new filter" do
    xhr :post, :create, :query => 'apples'

    @response.session[:filter].should.equal 'apples'
    template.should.be nil
  end

  specify "can clear a filter" do
    @request.session[:filter] = 'apples'

    xhr :delete, :destroy

    @response.session[:filter].should.be.nil
    template.should.be nil
  end
end
