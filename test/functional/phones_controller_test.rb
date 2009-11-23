require 'test_helper'

describe "PhonesController", ActionController::TestCase do
  use_controller PhonesController
  
  setup do
    login_as :quentin
    @account = accounts(:quentin)
  end
  
  context "Viewing phones" do
    specify "works" do
      get :index
      
      template.should.equal 'index'
      assigns(:phones).length.should.be 1
      assigns(:phones).first.should.equal phones(:quentin_phone)
    end
  end
  
  context "Downloading phone software" do
    specify "works" do
      SmsNotifier.expects(:deliver_sms_message).with { |recip, msg, sender|
        recip == '6165551212@messaging.sprintpcs.com'
      }
      
      put :download, {
        :phone_number => '6165551212',
        :phone_carrier => 'sprint'
      }
      
      json['status'].should.equal 'success'
    end
    
    specify "displays an error if phone number invalid" do
      SmsNotifier.expects(:deliver_sms_message).never
      
      put :download, {
        :phone_number => '123',
        :phone_carrier => 'sprint'
      }
      
      json['status'].should.equal 'failure'
      json['error'].should.not.be.nil
    end
  end
  
  context "Activating phones" do
    specify "works" do
      @account.phones.length.should.be 1
      
      post :activate, {
        :activation_code => 'EMPTY707'
      }
      
      json['status'].should.equal 'success'
      @account.reload.phones.length.should.be 2
      phones(:nobody_phone).account_id.should.equal @account.id
    end
    
    specify "displays an error if phone does not exist" do
      post :activate, {
        :activation_code => 'BLAHBLAHBLAH'
      }
      
      json['status'].should.equal 'failure'
      json['error'].should =~ /Unable to activate/
    end
    
    specify "displays an error if activation fails" do
      Phone.any_instance.expects(:activate).returns(false)
      
      post :activate, {
        :activation_code => 'AARON123'
      }
      
      json['status'].should.equal 'failure'
      json['error'].should =~ /already been activated/
    end
    
    specify "will return a custom error if appropriate" do
      Phone.expects(:count).returns(21)
      
      post :activate, {
        :activation_code => 'EMPTY707'
      }
      
      json['status'].should.equal 'failure'
      json['error'].should =~ /Maximum/
    end
  end
  
  context "Viewing a phone" do
    setup do
      @phone = phones(:quentin_phone)
    end
    
    specify "works" do
      get :show, {
        :id => @phone.id
      }
      
      template.should.equal 'show'
      assigns(:phone).id.should.equal @phone.id
    end
  end
  
  context "Editing phones" do
    setup do
      @phone = phones(:quentin_phone)
    end
    
    specify "displays edit page" do
      get :edit, {
        :id => @phone.id
      }
      
      template.should.equal 'edit'
      assigns(:phone).id.should.equal @phone.id
    end
    
    specify "works" do
      post :update, {
        :id => @phone.id,
        :phone => {
          :name => 'A new name'
        }
      }
      
      json['status'].should.equal 'success'
      @phone.reload
      @phone.name.should.equal 'A new name'
    end
    
    specify "handles user errors" do
      Phone.any_instance.expects(:update_attributes).returns(false)
      post :update, {
        :id => @phone.id,
        :phone => {
          :name => 'A new name'
        }
      }
      
      json['status'].should.equal 'failure'
      json['html'].should.not.be.nil
    end
  end
  
  context "Destroying (technically, unlinking) phones" do
    setup do
      @phone = phones(:quentin_phone)
    end
    
    specify "works" do
      Phone.should.differ(:count).by(0) do
        post :destroy, {
          :id => @phone.id
        }
      end
      
      json['status'].should.equal 'success'
      @account.reload.phones.should.be.empty
      @phone.reload.account.should.be.nil
    end
  end
end
