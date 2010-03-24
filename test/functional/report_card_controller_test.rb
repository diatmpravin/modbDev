require File.dirname(__FILE__) + '/../test_helper'

describe "ReportCardController", ActionController::TestCase do
  use_controller ReportCardController

  setup do
    login_as :quentin
    DeviceGroup.rebuild!
  end

  it "should show the report card" do
    get :show
    template.should.be "show"
  end

end
