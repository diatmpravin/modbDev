require File.expand_path(File.dirname(__FILE__) + '/test_helper')

class FinderTest < ActiveSupport::TestCase
  
  def setup
    PhonesDatabase.site = "http://localhost"

    @found = {
      :count => 3,
      :phones => [
        {:id => "1", :name => "Woot", :manufacturer_id => 1},
        {:id => "2", :name => "Got", :manufacturer_id => 1},
        {:id => "3", :name => "It", :manufacturer_id => 2},
      ]
    }.to_xml(:root => "finder")

    ActiveResource::HttpMock.respond_to do |mock| 
      # Pure query
      mock.get "/finder.xml?q=Query", {}, @found

      # Query with carrier
      mock.get "/finder.xml?carrier=1&q=Query", {}, @found

      # Query with manufacturer
      mock.get "/finder.xml?manufacturer=2&q=Query", {}, @found
      
      # Query with app
      mock.get "/finder.xml?app=3&q=Query", {}, @found
      
      # Query with pre-configured app
      mock.get "/finder.xml?app=3&q=PhoneName", {}, @found
      
      # Query with everything
      mock.get "/finder.xml?app=4&carrier=2&manufacturer=1&q=Query", {}, @found

      # Query with phone id
      mock.get "/finder.xml?app=4&carrier=2&id=2", {}, @found
      
    end
  end

  test "allows querying" do
    finder = PhonesDatabase::Finder.search(:query => "Query")
    assert_equal 3, finder.count
    assert_equal 3, finder.phones.length
  end

  test "query limits by manufacturer" do
    finder = PhonesDatabase::Finder.search(:query => "Query", :manufacturer => 2)
    assert_equal 3, finder.count
    assert_equal 3, finder.phones.length
  end

  test "query limits by carrier" do
    finder = PhonesDatabase::Finder.search(:query => "Query", :carrier => 1)
    assert_equal 3, finder.count
    assert_equal 3, finder.phones.length
  end

  test "query limits by app" do
    finder = PhonesDatabase::Finder.search(:query => "Query", :app => 3)
    assert_equal 3, finder.count
    assert_equal 3, finder.phones.length
  end

  test "query limits by everything" do
    finder = PhonesDatabase::Finder.search(:query => "Query", :manufacturer => 1, :carrier => 2, :app => 4)
    assert_equal 3, finder.count
    assert_equal 3, finder.phones.length
  end

  test "can also pass in a phone id" do
    finder = PhonesDatabase::Finder.search(:phone_id => 2, :carrier => 2, :app => 4)
    assert_equal 3, finder.count
    assert_equal 3, finder.phones.length
  end

  test "properly uses a pre-configured app_id value" do
    PhonesDatabase::Finder.app_id = 3

    finder = PhonesDatabase::Finder.search(:query => "PhoneName")

    assert_equal 3, finder.count
    assert_equal 3, finder.phones.length

    
    PhonesDatabase::Finder.app_id = nil
  end

end
