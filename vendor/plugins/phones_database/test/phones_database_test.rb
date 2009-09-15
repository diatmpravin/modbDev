require File.expand_path(File.dirname(__FILE__) + '/test_helper')

class PhonesDatabaseTest < ActiveSupport::TestCase
  
  def setup
    PhonesDatabase.site = "http://phones.local"
  end

  test "models are created" do
    assert defined?(PhonesDatabase::Carrier)
    assert defined?(PhonesDatabase::Manufacturer)
    assert defined?(PhonesDatabase::Phone)
    assert defined?(PhonesDatabase::Finder)
  end

  test "ARes::Base models are given the site url" do
    [PhonesDatabase::Carrier, 
      PhonesDatabase::Manufacturer, 
      PhonesDatabase::Phone,
      PhonesDatabase::Finder].each do |klass|

      assert_equal "phones.local", klass.site.host
      assert_equal 80, klass.site.port
    end
  end

  test "Can configure app id" do
    PhonesDatabase.app_id = 10
    assert_equal 10, PhonesDatabase::Finder.app_id
    PhonesDatabase.app_id = nil
  end

  test "can configure image host(s)"

  test "exposes an actionview helper that works with configured image host(s)" do
    assert ActionView::Base.instance_methods.include?("phone_image_tag")

    view = ActionView::Base.new
    image = view.phone_image_tag("image.png")
    assert_match(%r{http://phones\.local/image.png}, image)
  end

  test "view helper doesn't include credentials" do
    PhonesDatabase.site = "http://user:password@phones.local"

    view = ActionView::Base.new
    image = view.phone_image_tag("image.png")
    assert_match(%r{http://phones\.local/image.png}, image)
  end

end
