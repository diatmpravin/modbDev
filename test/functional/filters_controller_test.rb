require 'test_helper'

describe "FiltersController", ActionController::TestCase do
  use_controller FiltersController

  setup do
    login_as :quentin
    @account = accounts(:quentin)
  end

  context "Create" do

    specify "can create a basic filter" do
      xhr :post, :create, :class => "Device", :query => 'apples'

      get_filter(Device)[:full].should.equal 'apples'
      get_filter(Device)[:query].should.equal 'apples'
    end

    specify "redirects to the location specified in :return_to" do
      xhr :post, :create, :query => 'apples', :return_to => "/devices"
      should.redirect_to "/devices"
    end

    specify "can parse out a field" do
      xhr :post, :create, :class => "Geofence", :query => 'name: apples'

      get_filter(Geofence)[:full].should.equal 'name: apples'
      get_filter(Geofence)[:name].should.equal 'apples'
    end

    specify "can parse out multiple fields" do
      xhr :post, :create, :class => "TestClass", :query => 'name: apples title: This is cool value: 1'

      get_filter("TestClass")[:full].should.equal 'name: apples title: This is cool value: 1'
      get_filter("TestClass")[:name].should.equal 'apples'
      get_filter("TestClass")[:title].should.equal 'This is cool'
      get_filter("TestClass")[:value].should.equal '1'
    end

    specify "can handle complex queries" do
      xhr :post, :create, :class => "Device", :query => 'all name: apples | oranges title: 4 & (5 | 6)'

      get_filter(Device)[:full].should.equal 'all name: apples | oranges title: 4 & (5 | 6)'
      get_filter(Device)[:query].should.equal 'all'
      get_filter(Device)[:name].should.equal 'apples | oranges'
      get_filter(Device)[:title].should.equal '4 & (5 | 6)'
    end

    specify "can mix basic query with fields" do
      xhr :post, :create, :class => "Device", :query => 'testing name: apples'

      get_filter(Device)[:full].should.equal "testing name: apples"
      get_filter(Device)[:query].should.equal 'testing'
      get_filter(Device)[:name].should.equal 'apples'
    end

    specify "Empty query nils out the field" do
      set_filter Device, "apples"

      xhr :post, :create, :class => "Device", :query => ''

      get_filter(Device).should.be.nil
    end

  end

  context "Destroy" do

    specify "can clear a filter" do
      set_filter Geofence, 'apples'
      set_filter Device, 'oranges'

      xhr :delete, :destroy, :class => "Geofence"

      get_filter(Geofence).should.be.nil
      get_filter(Device).should.not.be.nil
      template.should.be nil
    end

    specify "redirects to the location specified in :return_to" do
      xhr :post, :destroy, :return_to => "/devices"
      should.redirect_to "/devices"
    end

  end
end
