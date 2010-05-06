require 'test_helper'

describe "UsersController", ActionController::TestCase do
  use_controller UsersController
  
  context "Listing users" do
    setup do
      @user = users(:quentin)
      login_as :quentin
    end
    
    specify "list works" do
      get :index
      
      should.redirect_to dashboard_path(:anchor => 'users')
      #template.should.equal 'index'
    end

    specify "list xhr works" do
      xhr :get, :index

      template.should.be '_tree'
      assigns(:users).length.should.not.be.nil
    end
    
    specify "requires USER role" do
      @user.update_attributes(:roles => [User::Role::FLEET])
      login_as :quentin
      
      get :index
      
      response.status.should.equal 403
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
      Mailer.deliveries.clear
      
      User.should.differ(:count).by(1) do
        post :create, {
          :user => {
            :login => 'wumpus',
            :name => 'Hunt The Wumpus',
            :email => 'wumpus@wumpus.com'
          }
        }
      end
      
      Mailer.deliveries.length.should.be 1
      
      # Should have an account
      wumpus = User.find_by_login 'wumpus'
      wumpus.account.should.not.be.nil
      
      json.length.should.be 1
      json['status'].should.equal 'success'
    end
    
    specify "handles errors gracefully" do
      post :create, {
        :user => {
          :name => 'Hunt The Wumpus',
          :email => 'wumpus@wumpus.com'
        }
      }
      
      json['status'].should.equal 'failure'
      template.should.equal '_form'
      assigns(:user).errors.on(:login).should.equal "can't be blank"
    end

    specify "requires USER role" do
      @user.update_attributes(:roles => [User::Role::FLEET])
      login_as :quentin
      
      get :new
      
      response.status.should.be 403
 
      post :create, {
        :user => {
          :name => 'Hunt The Wumpus',
          :email => 'wumpus@wumpus.com'
        }
      }
      
      response.status.should.be 403
    end
  end
  
  context "Viewing and editing a user" do
    setup do
      @user = users(:child)
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
      
      json.length.should.be 1
      json['status'].should.equal 'success'
      @user.reload.name.should.equal 'Much Better Name'
    end
    
    specify "handles errors gracefully" do
      put :update, {
        :id => @user.id,
        :user => {
          :login => ''
        }
      }
      
      json['status'].should.equal 'failure'
      template.should.equal '_form'
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
      users(:quentin).update_attributes(:roles => [User::Role::FLEET])
      
      get :edit, {
        :id => @user.id
      }
      
      response.status.should.be 403
      
      put :update, {
        :id => @user.id,
        :user => {
          :name => 'Much Better Name'
        }
      }
      
      response.status.should.be 403
    end

    specify "prevents editing self" do
      get :edit, {
        :id => users(:quentin).id
      }
    
      response.status.should.be 403

      put :update, {
        :id => users(:quentin).id,
        :user => {
          :name => 'Much Better Name'
        }
      }

      response.status.should.be 403
    end
  end
  
  context "Removing a user" do
    setup do
      @user = users(:child)
      login_as :quentin
    end
    
    specify "works" do
      User.should.differ(:count).by(-1) do
        delete :destroy, {
          :id => @user.id
        }
      end
      
      json['status'].should.equal 'success'
    end
    
    specify "prevents access to other accounts" do
      User.should.differ(:count).by(0) do
        delete :destroy, {
          :id => users(:aaron).id
        }
      end
    end
    
    specify "requires USER role" do
      users(:quentin).update_attributes(:roles => [User::Role::FLEET])
      login_as :quentin
      
      delete :destroy, {
        :id => users(:child).id
      }
      
      response.status.should.be 403
    end

    specify "prevents removal of self" do
      users(:quentin).update_attributes(:roles => [User::Role::USERS])
      login_as :quentin
    
      delete :destroy, {
        :id => users(:quentin).id
      }

      response.status.should.be 403
    end
  end
  

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
      
      should.redirect_to root_path
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
  
  context "Setting Password" do
    setup do
      @user = users(:quentin)
      @user.update_attribute(:password_reset_code, 'blah')
    end
    
    specify "can see set password page" do
      get :set_password, {:id => 'blah'}
      
      template.should.equal 'set_password'
    end
    
    specify "redirect for invalid" do
      get :set_password, {:id => 'bad'}
      
      should.redirect_to forgot_password_path
      flash[:error].should.not.be.nil
    end
    
    specify "can set the password" do
      @user.should.be.authenticated('test')
      
      post :set_password, {
        :id => 'blah',
        :password => 'halb',
        :password_confirmation => 'halb'
      }
      
      should.redirect_to root_path
      flash[:notice].should =~ /Welcome/
      
      @user.reload
      @user.should.be.authenticated('halb')
    end
    
    specify "will fail if bad password" do
      post :set_password, {
        :id => 'blah',
        :password => 'blahblah',
        :password_confirmation => 'doubleblah'
      }
      
      template.should.equal 'set_password'
      assigns(:user).errors.on(:password).should.not.be.nil
    end
  end
end
