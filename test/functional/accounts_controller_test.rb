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
    end
    
    specify "redirects if account is not a reseller" do
      accounts(:quentin).update_attribute(:reseller, false)
      get :index
      
      should.redirect_to root_path
    end
    
    specify "redirects if user is not a superuser" do
      users(:quentin).update_attribute(:roles, [User::Role::FLEET])
      get :index
      
      should.redirect_to root_path
    end
  end
  
  context "Creating an account" do
    specify  "displays the new account form" do
      get :new
      
      template.should.equal 'new'
      assigns(:account).should.not.be.nil
    end
    
    specify "works" do
      Mailer.deliveries.clear
      
      Account.should.differ(:count).by(1) do
        post :create, {
          :account => {
            :reseller => '0',
            :can_assign_reseller => '0',
            :name => 'ooga',
            :users_attributes => {'0' => {
              :login => 'oogabooga',
              :name => 'Ooga Booga',
              :email => 'ooga@booga.com',
              :password => 'test',
              :password_confirmation => 'test'
            }}
          }
        }
      end
      
      Mailer.deliveries.length.should.be 1
      
      account = Account.find_by_name 'ooga'
      account.users.count.should.equal 1
      account.parent.should.equal accounts(:quentin)
      
      should.redirect_to :action => 'index'
    end
    
    specify "handles errors" do
      post :create, {
        :account => {
          :reseller => '0',
          :can_assign_reseller => '0',
          :users_attributes => { '0' => {
            :login => 'oogabooga',
            :email => 'ooga@booga.com',
            }}
        }
      }
        
      template.should.equal 'new'
      assigns(:account).errors.on('name').should.not.be.nil
    end
  end
  
  context "Editing an account" do
    setup do
      @new_account = accounts(:quentin).children.create(
        :name => 'New Company'
      )
    end
    
    specify  "displays the edit account form" do
      get :edit, {:id => @new_account.id}
      
      template.should.equal 'edit'
      assigns(:account).should.not.be.nil
    end
    
    specify "works" do
      put :update, {
        :id => @new_account.id,
        :account => {
          :name => 'Not So New'
        }
      }
      
      @new_account.reload.name.should.equal 'Not So New'
      
      should.redirect_to :action => 'index'
    end
    
    specify "handles errors" do
      put :update, {
        :id => @new_account.id,
        :account => {
          :name => ''
        }
      }
      
      template.should.equal 'edit'
      assigns(:account).errors.on('name').should.not.be.nil
    end
  end
  
end
