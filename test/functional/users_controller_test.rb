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
  
  context "Listing users" do
    setup do
      @user = users(:quentin)
      login_as :quentin
    end
    
    specify "list works" do
      get :index
      
      template.should.equal 'index'
    end
    
    specify "requires USER role" do
      @user.update_attributes(:roles => [User::Role::FLEET])
      login_as :quentin
      
      get :index
      
      should.redirect_to root_path
    end
  end
  
  context "Creating a user" do
    setup do
      @user = users(:quentin)
      login_as :quentin
    end
    
    specify "displays the new user form" do
      get :new
      
      template.should.equal 'new'
      assigns(:user).account.should.equal accounts(:quentin)
    end
    
    specify "works" do
      User.should.differ(:count).by(1) do
        post :create, {
          :user => {
            :login => 'wumpus',
            :name => 'Hunt The Wumpus',
            :email => 'wumpus@wumpus.com'
          }
        }
      end
      
      #should have an account
      wumpus = User.find_by_login 'wumpus'
      wumpus.account.should.not.be.nil
      
      should.redirect_to :action => 'index'
    end
    
    specify "handles errors gracefully" do
      post :create, {
        :user => {
          :name => 'Hunt The Wumpus',
          :email => 'wumpus@wumpus.com'
        }
      }
      
      template.should.equal 'new'
      assigns(:user).errors.on(:login).should.equal "can't be blank"
    end

    specify "requires USER role" do
      @user.update_attributes(:roles => [User::Role::FLEET])
      login_as :quentin
      
      get :new
      
      should.redirect_to root_path
      
      post :create, {
        :user => {
          :name => 'Hunt The Wumpus',
          :email => 'wumpus@wumpus.com'
        }
      }
      
      should.redirect_to root_path
    end
  end
  
  context "Viewing and editing a user" do
    setup do
      @user = users(:quentin)
      login_as :quentin
    end
    
    specify "displays user edit form" do
      get :edit, {
        :id => @user.id
      }
      
      template.should.equal 'edit'
      assigns(:user).should.equal @user
    end
    
    specify "works" do
      put :update, {
        :id => @user.id,
        :user => {
          :name => 'Much Better Name'
        }
      }
      
      should.redirect_to :action => 'index'
      @user.reload.name.should.equal 'Much Better Name'
    end
    
    specify "handles errors gracefully" do
      put :update, {
        :id => @user.id,
        :user => {
          :login => ''
        }
      }
      
      template.should.equal 'edit'
      assigns(:user).errors.on(:login).should.equal "can't be blank"
    end
    
    specify "prevents access to other accounts" do
      put :update, {
        :id => users(:aaron).id,
        :user => {
          :name => 'Much Better Name'
        }
      }

      should.redirect_to :action => 'index'
    end
    
    specify "requires USER role" do
      @user.update_attributes(:roles => [User::Role::FLEET])
      login_as :quentin
      
      get :edit, {
        :id => @user.id
      }
      
      should.redirect_to root_path
      
      put :update, {
        :id => @user.id,
        :user => {
          :name => 'Much Better Name'
        }
      }
      
      should.redirect_to root_path
    end
  end
  
  context "Removing a user" do
    setup do
      @user = users(:quentin)
      login_as :quentin
    end
    
    specify "works" do
      User.should.differ(:count).by(-1) do
        delete :destroy, {
          :id => @user.id
        }
      end
      
      should.redirect_to :action => 'index'
    end
    
    specify "prevents access to other accounts" do
      User.should.differ(:count).by(0) do
        delete :destroy, {
          :id => users(:aaron).id
        }
      end
    end
    
    specify "requires USER role" do
      @user.update_attributes(:roles => [User::Role::FLEET])
      login_as :quentin
      
      delete :destroy, {
        :id => @user.id
      }
      
      should.redirect_to root_path
    end
  end
end
