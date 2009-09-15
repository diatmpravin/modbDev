require 'test_helper'

describe "Dispatch Controller", ActionController::TestCase do
  use_controller DispatchController
  
  context "Handling requests" do
    specify "passes requests to Dispatch Server controller" do
      Dispatch::Controller.expects(:dispatch).with('{"request":1}').
        returns('{"code":0}\n')
        
      get :index, {
        :msg => '{"request":1}'
      }
      
      body.should.equal '{"code":0}\n'
    end
  end
end
