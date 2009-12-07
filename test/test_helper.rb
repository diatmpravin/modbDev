ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'test_help'
require 'test/spec/rails'
require 'freeze_time'
require 'mocha'

# Request Forgery Protection hack
# form_authenticity_token causes an error in test mode because protect_against_forgery is turned off.
module ActionController
  module RequestForgeryProtection
    def form_authenticity_token
      return "form_authenticity_token OVERRIDE!"
    end
  end
end

class ActiveSupport::TestCase
  include AuthenticatedTestHelper

  # Transactional fixtures accelerate your tests by wrapping each test method
  # in a transaction that's rolled back on completion.  This ensures that the
  # test database remains unchanged so your fixtures don't have to be reloaded
  # between every test method.  Fewer database queries means faster tests.
  #
  # Read Mike Clark's excellent walkthrough at
  #   http://clarkware.com/cgi/blosxom/2005/10/24#Rails10FastTesting
  #
  # Every Active Record database supports transactions except MyISAM tables
  # in MySQL.  Turn off transactional fixtures in this case; however, if you
  # don't care one way or the other, switching from MyISAM to InnoDB tables
  # is recommended.
  #
  # The only drawback to using transactional fixtures is when you actually
  # need to test transactions.  Since your test is bracketed by a transaction,
  # any transactions started in your code will be automatically rolled back.
  self.use_transactional_fixtures = true

  # Instantiated fixtures are slow, but give you @david where otherwise you
  # would need people(:david).  If you don't want to migrate your existing
  # test cases which use the @david style and don't mind the speed hit (each
  # instantiated fixtures translates to a database query per test method),
  # then set this back to true.
  self.use_instantiated_fixtures  = false

  # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  fixtures :all

  # Helper for JSON actions
  def json
    @_json ||= ActiveSupport::JSON.decode(response.body)
  end

  # Take a query string and put a parsed hash in the session
  def set_filter(klass, query)
    @request.session[:filter] ||= {}
    @request.session[:filter][klass.to_s] = FilterQuery.parse(query)
  end

  # Pull out the filter string for a given class, if it exists
  def get_filter(klass)
    @request.session[:filter][klass.to_s]
  end
end

MapQuest # kickstart autoloader
module MapQuest
  def MapQuest::call(server_type, request_xml)
    raise 'Attempt to contact MapQuest in a test (missing mock or stub!)'
  end

  class Session
    protected
    def authenticate(xml)
      xml.Authentication # no need for authentication in tests
    end
  end

  # Use fixtures for various tiling tests
  module Tile
    remove_const 'CACHE'
    CACHE = File.join(Rails.root, 'test', 'fixtures', 'tmp', 'cache')

    remove_const 'FORMAT'
    FORMAT = MapQuest::ContentType::GIF
  end
end
