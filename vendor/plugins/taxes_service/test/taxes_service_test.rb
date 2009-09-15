require 'test_helper'

class TaxesServiceTest < ActiveSupport::TestCase

  def setup
    TaxesService.site = "http://taxes.local"
  end

  test "models are created" do
    assert defined?(TaxesService::Taxes)
  end

  test "ARes::Base models are given the site url" do
    assert_equal "taxes.local", TaxesService::Taxes.site.host
    assert_equal 80, TaxesService::Taxes.site.port
  end

end
