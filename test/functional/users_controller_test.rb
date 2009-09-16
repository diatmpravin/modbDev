require 'test_helper'

describe "UsersController", ActionController::TestCase do
  use_controller UsersController
  
  context "Forgotten Password" do
    setup do
      @user = users(:quentin)
    end
    
    specify "can see the forgotten password page" do
      get :forgot_password
      
      template.should.equal 'forgot_password'
    end
    
    specify "can submit a forgotten password request" do
      User.any_instance.expects(:forgot_password)
      
      post :forgot_password, {
        :account_number => 10001,
        :login => 'quentin'
      }
      
      should.redirect_to login_path
    end
    
    specify "will fail if credentials are incorrect" do
      User.any_instance.expects(:forgot_password).never
      
      post :forgot_password, {
        :account_number => 55555,
        :login => 'quentin'
      }
      
      template.should.equal 'forgot_password'
      flash[:error].should.not.be.nil
      
      post :forgot_password, {
        :account_number => 10001,
        :login => 'quotient'
      }
      
      template.should.equal 'forgot_password'
      flash[:error].should.not.be.nil
    end
  end
  
  context "Reset Password" do
    setup do
      @user = users(:quentin)
      @user.update_attribute(:password_reset_code, 'fish')
    end
    
    specify "can see the password reset page" do
      get :reset_password, {:id => 'fish'}
      
      template.should.equal 'reset_password'
    end
    
    specify "will be redirected if reset code is invalid" do
      get :reset_password, {:id => 'trouble'}
      
      should.redirect_to forgot_password_path
      flash[:error].should.not.be.nil
    end
    
    specify "can reset the user's password" do
      @user.should.be.authenticated('test')
      
      post :reset_password, {
        :id => 'fish',
        :password => 'salmon',
        :password_confirmation => 'salmon'
      }
      
      should.redirect_to login_path
      flash[:notice].should.not.be.nil
      
      @user.reload
      @user.should.be.authenticated('salmon')
      @user.password_reset_code.should.be.nil
    end
    
    specify "will fail if user cannot be saved" do
      post :reset_password, {
        :id => 'fish',
        :password => 'salmon',
        :password_confirmation => 'halibut'
      }
      
      template.should.equal 'reset_password'
      assigns(:user).errors.on(:password).should.not.be.nil
    end
  end
end
