require File.expand_path(File.dirname(__FILE__) + '/test_helper')

class ManufacturerTest < ActiveSupport::TestCase
  
  def setup
    PhonesDatabase.site = "http://localhost"

    @manfs = [
      {:id => '1', :name => "RIM"},
      {:id => '2', :name => "Apple"}
    ].to_xml(:root => "manufacturers")

    @manf = {:id => "1", :name => "Woot"}.to_xml(:root => "manufacturer")

    @phones = [
      {:id => "1", :name => "Pearl"},
      {:id => "2", :name => "i960"},
      {:id => "3", :name => "RAZR"}
    ].to_xml(:root => "phones")

    ActiveResource::HttpMock.respond_to do |mock| 
      mock.get "/manufacturers.xml",   {}, @manfs
      mock.get "/manufacturers/1.xml", {}, @manf

      mock.get "/phones.xml?manufacturer_id=1", {}, @phones
    end
  end

  test "can get list of carriers" do
    m = PhonesDatabase::Manufacturer.find(:all)
    assert 2, m.length
  end

  test "can get the list of phones for a manufacturer" do
    m = PhonesDatabase::Manufacturer.find(1)
    assert_equal "Woot", m.name
    assert_equal 3, m.phones.length
  end

end
