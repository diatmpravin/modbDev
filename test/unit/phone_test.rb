require 'test_helper'

describe "Phone", ActiveSupport::TestCase do
  setup do
    @account = accounts(:quentin)
    @phone = phones(:quentin_phone)
    @device = devices(:quentin_device)
  end
  
  context "Associations" do
    specify "belongs to an account" do
      @phone.should.respond_to(:account)
      @phone.account.should.equal @account
    end
    
    specify "has many devices" do
      @phone.should.respond_to(:devices)
      @phone.devices.should.include(@device)
    end
  end
  
  context "Validations" do
    specify "enforces number of records" do
      Phone.delete_all
      20.times do |i|
        p = @account.phones.new(:name => 'Phone X')
        p.should.save
      end
      p = @account.phones.new(:name => 'Phone X')
      p.should.not.be.valid
      p.errors.on(:base).should =~ /Maximum/
      
      # Make sure we can update
      p = Phone.last
      p.name = 'New Name'
      p.should.save
      
      # Make sure we can NOT update a phone and point it to this account
      p = Phone.new(:name => 'Phone Y')
      p.should.save
      p.account = @account
      p.should.not.save
      p.errors.on(:base).should =~ /Maximum/
    end
  end
  
  context "Activating" do
    specify "works" do
      phone = phones(:nobody_phone)
      
      phone.should.activate(@account)
      phone.reload.account.should.equal @account
      @account.reload.phones.should.include(phone)
    end
    
    specify "fails if already activated" do
      phone = phones(:aaron_phone)
      
      phone.should.not.activate(@account)
      phone.reload.account.should.not.equal @account
    end
    
    specify "automatically controls any existing devices" do
      phone = phones(:nobody_phone)
      phone.devices.should.be.empty
      
      phone.should.activate(@account)
      phone.reload.devices.should.include(@device)
    end
  end
  
  specify "protects appropriate attributes" do
    phone = Phone.new(:account_id => 7,
      :moshi_key => 'key', :activation_code => 'code')
    phone.account_id.should.be.nil
    phone.moshi_key.should.be.nil
    phone.activation_code.should.be.nil
    
    phone = Phone.new(:name => 'New', :account => @account)
    phone.name.should.equal 'New'
    phone.account_id.should.equal @account.id
  end
  
  specify "allows device_ids=, but enforces account ownership" do
    @phone.update_attributes(:device_ids => [])
    @phone.devices.should.be.empty
    
    @phone.update_attributes(:device_ids => [@device.id])
    @phone.devices.should.include(@device)
    
    should.raise(ActiveRecord::RecordNotFound) do
      bad = devices(:aaron_device)
      @phone.update_attributes(:device_ids => [@device.id, bad.id])
    end
  end
end
