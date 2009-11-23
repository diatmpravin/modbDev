require 'test_helper'

describe "FiltersController", ActionController::TestCase do
  use_controller FiltersController

  setup do
    login_as :quentin
    @account = accounts(:quentin)
  end

  context "Create" do

    specify "can create a basic filter" do
      xhr :post, :create, :query => 'apples'

      @response.session[:filter][:full].should.equal 'apples'
      @response.session[:filter][:query].should.equal 'apples'
      template.should.be nil
    end

    specify "can parse out a field" do
      xhr :post, :create, :query => 'name: apples'

      @response.session[:filter][:full].should.equal 'name: apples'
      @response.session[:filter][:name].should.equal 'apples'
      template.should.be nil
    end

    specify "can parse out multiple fields" do
      xhr :post, :create, :query => 'name: apples title: This is cool value: 1'

      @response.session[:filter][:full].should.equal 'name: apples title: This is cool value: 1'
      @response.session[:filter][:name].should.equal 'apples'
      @response.session[:filter][:title].should.equal 'This is cool'
      @response.session[:filter][:value].should.equal '1'
      template.should.be nil
    end

    specify "can handle complex queries" do
      xhr :post, :create, :query => 'all name: apples | oranges title: 4 & (5 | 6)'

      @response.session[:filter][:full].should.equal 'all name: apples | oranges title: 4 & (5 | 6)'
      @response.session[:filter][:query].should.equal 'all'
      @response.session[:filter][:name].should.equal 'apples | oranges'
      @response.session[:filter][:title].should.equal '4 & (5 | 6)'
      template.should.be nil
    end

    specify "can mix basic query with fields" do
      xhr :post, :create, :query => 'testing name: apples'

      @response.session[:filter][:full].should.equal "testing name: apples"
      @response.session[:filter][:query].should.equal 'testing'
      @response.session[:filter][:name].should.equal 'apples'
      template.should.be nil
    end

  end

  context "Destroy" do

    specify "can clear a filter" do
      @request.session[:filter] = 'apples'

      xhr :delete, :destroy

      @response.session[:filter].should.be.nil
      template.should.be nil
    end

  end
end
