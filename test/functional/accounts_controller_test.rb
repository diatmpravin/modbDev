require 'test_helper'

describe "Accounts Controller", ActionController::TestCase do
  use_controller AccountsController
  
  setup do
    login_as :quentin
  end
  
  context "Account List" do
    specify "works" do
      get :index
      
      template.should.equal 'index'
      assigns(:accounts).should.equal [accounts(:aaron)]
    end
    
    specify "redirects if account is not a reseller" do
      accounts(:quentin).update_attribute(:reseller, false)
      get :index
      
      should.redirect_to root_path
    end
    
    specify "redirects if user is not a superuser" do
      users(:quentin).update_attribute(:roles, [User::Role::DISPATCH])
      get :index
      
      should.redirect_to root_path
    end
  end
  
end
