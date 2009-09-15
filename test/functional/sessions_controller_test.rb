require 'test_helper'

describe "Sessions Controller", ActionController::TestCase do
  use_controller SessionsController
  
  context "Authentication" do
    setup do
      @request    = ActionController::TestRequest.new
      @response   = ActionController::TestResponse.new
    end
  
    specify "should login and redirect" do
      post :create, :account_number => 10001, :login => 'quentin', :password => 'test'
      assert session[:user_id]
      assert_response :redirect
    end

    specify "should fail login and not redirect (bad password)" do
      post :create, :account_number => 10001, :login => 'quentin', :password => 'bad password'
      assert_nil session[:user_id]
      assert_response :success
    end
    
    specify "should fail login and not redirect (wrong account)" do
      post :create, :account_number => 10005, :login => 'quentin', :password => 'test'
      assert_nil session[:user_id]
      assert_response :success
    end
    
    specify "should logout" do
      login_as :quentin
      get :destroy
      assert_nil session[:user_id]
      assert_response :redirect
    end

    specify "should remember me" do
      post :create, :account_number => 10001, :login => 'quentin', :password => 'test', :remember_me => "1"
      assert_not_nil @response.cookies["auth_token"]
    end

    specify "should not remember me" do
      post :create, :account_number => 10001, :login => 'quentin', :password => 'test', :remember_me => "0"
      assert_nil @response.cookies["auth_token"]
    end
    
    specify "should delete token on logout" do
      login_as :quentin
      get :destroy
      @response.cookies["auth_token"].should.be nil
    end

    specify "should login with cookie" do
      users(:quentin).remember_me
      @request.cookies["auth_token"] = cookie_for(:quentin)
      get :new
      assert @controller.send(:logged_in?)
    end

    specify "should fail expired cookie login" do
      users(:quentin).remember_me
      users(:quentin).update_attribute :remember_token_expires_at, 5.minutes.ago
      @request.cookies["auth_token"] = cookie_for(:quentin)
      get :new
      assert !@controller.send(:logged_in?)
    end

    specify "should fail cookie login" do
      users(:quentin).remember_me
      @request.cookies["auth_token"] = auth_token('invalid_auth_token')
      get :new
      assert !@controller.send(:logged_in?)
    end

    protected
    def auth_token(token)
      CGI::Cookie.new('name' => 'auth_token', 'value' => token)
    end
    
    def cookie_for(user)
      auth_token users(user).remember_token
    end
  end
end
