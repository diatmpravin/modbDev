require 'test_helper'

# Tests for the Dispatch::Controller construct/framework.
# See test/functional for individual Dispatch:: controllers.
describe "Dispatch Framework", ActiveSupport::TestCase do
  setup do
    # Set up a fake controller
    module Dispatch
      class FakeParent < Controller
        filter :fake_filter
        
        def fake_filter
          if request[:action] == 'parents'
            {:code => 9}
          else
            true
          end
        end
      end
      
      class FakeController < FakeParent
        filter :other_filter
        filter :specific_filter, :except => :index
        filter :last_filter, :except => [:get, :index]
        
        def index
          {:message => request[:x]}
        end
        
        def hooray
          {:code => 7, :string => 'hello'}
        end
        
        def parents
          {:code => 3}
        end
        
        def other_filter
          true
        end
        
        def specific_filter
          true
        end
        
        def last_filter
          {:code => 3, :message => 'filtered'}
        end
      end
    end
  end
  
  context "Dispatching actions" do
    specify "handles a dispatched request" do
      response = Dispatch::Controller.dispatch('{"controller":"fake","action":"index","x":7}')
      
      response = ActiveSupport::JSON.decode(response)
      response['code'].should.equal 0
      response['message'].should.equal 7
    end
    
    specify "errors if the action does not exist" do
      response = Dispatch::Controller.dispatch('{"controller":"fake","action":"argh"}')
      
      response = ActiveSupport::JSON.decode(response)
      response['code'].should.equal 2
    end
    
    specify "errors if the controller does not exist" do
      response = Dispatch::Controller.dispatch('{"controller":"nada","action":"nope"}')
      
      response = ActiveSupport::JSON.decode(response)
      response['code'].should.equal 2
    end
    
    specify "gets stopped by filter chain if appropriate" do
      response = Dispatch::Controller.dispatch('{"controller":"fake","action":"hooray"}')
      
      response = ActiveSupport::JSON.decode(response)
      response['code'].should.equal 3
      response['message'].should.equal 'filtered'
    end
    
    specify "inherits filters from parent" do
      response = Dispatch::Controller.dispatch('{"controller":"fake","action":"parents"}')
      
      response = ActiveSupport::JSON.decode(response)
      response['code'].should.equal 9
    end
  end
end
