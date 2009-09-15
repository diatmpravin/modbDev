require File.expand_path(File.dirname(__FILE__) + '/test_helper')

class CarrierTest < ActiveSupport::TestCase
  
  def setup
    PhonesDatabase.site = "http://localhost"

    @carriers = [
      {:id => '1', :name => "Sprint"},
      {:id => '2', :name => "AT&T"}
    ].to_xml(:root => "carriers")

    ActiveResource::HttpMock.respond_to do |mock| 
      mock.get "/carriers.xml",   {}, @carriers
    end
  end

  test "can get list of carriers" do
    c = PhonesDatabase::Carrier.find(:all)
    assert 2, c.length
  end

end
