require 'test_helper'

describe "Accounts Controller", ActionController::TestCase do
  use_controller AccountsController
  
  context "Authentication" do
    setup do
      @request    = ActionController::TestRequest.new
      @response   = ActionController::TestResponse.new
    end

    specify "should allow signup" do
      assert_difference 'Account.count' do
        create_account
        assert_response :success
      end
    end

    specify "should require login on signup" do
      assert_no_difference 'Account.count' do
        create_account(:login => nil)
        assert assigns(:account).errors.on(:login)
        assert_response :success
      end
    end

    specify "should require password on signup" do
      assert_no_difference 'Account.count' do
        create_account(:password => nil)
        assert assigns(:account).errors.on(:password)
        assert_response :success
      end
    end

    specify "should require password confirmation on signup" do
      assert_no_difference 'Account.count' do
        create_account(:password_confirmation => nil)
        assert assigns(:account).errors.on(:password_confirmation)
        assert_response :success
      end
    end

    specify "should require email on signup" do
      assert_no_difference 'Account.count' do
        create_account(:email => nil)
        assert assigns(:account).errors.on(:email)
        assert_response :success
      end
    end
    
    protected
    def create_account(options = {})
      post :create, :account => { :login => 'quire', :email => 'quire@example.com',
        :password => 'quire', :password_confirmation => 'quire' }.merge(options)
    end
  end
  
  context "Updating account settings" do
    setup do
      login_as :quentin
      @account = accounts(:quentin)
    end
    
    specify "shows an edit form" do
      @account.subscription.update_attribute(:next_bill_date, Date.today)

      get :edit
      
      template.should.be 'edit'
      assigns(:account).should.equal @account
      assigns(:subscription).should.equal @account.subscription
    end
    
    specify "works" do
      put :update, {
        :account => {
          :current_password => 'test',
          :email => 'new email',
          :password => 'new password',
          :password_confirmation => 'new password'
        }
      }
      
      template.should.be 'edit'
      @account.reload
      @account.email.should.equal 'new email'
      @account.should.be.authenticated('new password')
      flash[:error].should.be.nil
      flash[:notice].should.not.be.nil
    end
    
    specify "fails if current password is not correct" do
      put :update, {
        :account => {
          :email => 'new email',
          :password => 'new password',
          :password_confirmation => 'new password'
        }
      }
      
      template.should.be 'edit'
      flash[:error].should.not.be.nil
    end
    
    specify "handles errors gracefully" do
      Account.any_instance.expects(:update_attributes).returns(false)
      
      put :update, {
        :password => 'test',
        :account => {
          :email => 'new email',
          :password => 'new password',
          :password_confirmation => 'new password'
        }
      }
      
      template.should.be 'edit'
      flash[:error].should.not.be.nil
    end
  end
  
  context "Destroying an account (JSON only)" do
    setup do
      login_as :quentin
      @account = accounts(:quentin)
    end
    
    specify "works" do
      account_id = @account.id
      Mailer.expects(:deliver_account_cancelled).with(@account)
      delete :destroy, {
        :password => 'test',
        :format => 'json'
      }
      
      json['status'].should.equal 'success'
      Account.find_by_id(account_id).should.be.nil
    end
    
    specify "requires current password" do
      delete :destroy, {
        :password => 'not test',
        :format => 'json'
      }
      
      json['status'].should.equal 'failure'
      json['error'].should =~ /You must enter your current password/
    end
  end
end
