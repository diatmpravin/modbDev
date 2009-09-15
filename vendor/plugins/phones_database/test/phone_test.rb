require File.expand_path(File.dirname(__FILE__) + '/test_helper')

class PhoneTest < ActiveSupport::TestCase
  
  def setup
    PhonesDatabase.site = "http://localhost"

    @phones = [
      {:id => "1", :name => "Pearl"},
      {:id => "2", :name => "i960"},
      {:id => "3", :name => "RAZR"}
    ].to_xml(:root => "phones")

    @phone = {:id => "2", :name => "i960", :manufacturer_id => "1"}.to_xml(:root => "phone")

    @manf = {:id => "1", :name => "Woot"}.to_xml(:root => "manufacturer")

    ActiveResource::HttpMock.respond_to do |mock| 
      mock.get "/phones.xml",   {}, nil, 404
      mock.get "/phones/1.xml", {}, @phone
      mock.get "/phones.xml?manufacturer_id=1", {}, @phones
      mock.get "/manufacturers/1.xml", {}, @manf
    end
  end

  test "can't just get a list of phones" do
    assert_raise ActiveResource::ResourceNotFound do
      PhonesDatabase::Phone.find(:all)
    end
  end

  test "can get list of phones for a given manufacturer" do
    phones = PhonesDatabase::Phone.find_all_by_manufacturer_id(1)
    assert_equal 3, phones.length
  end

  test "can get a phone by id" do
    p = PhonesDatabase::Phone.find(1)
    assert_equal "i960", p.name
  end

  test "can get manufacturer for a given phone" do
    p = PhonesDatabase::Phone.find(1)
    assert_equal "Woot", p.manufacturer.name
  end

end
