require 'test_helper'

describe "Account", ActiveSupport::TestCase do
  setup do
    Account.rebuild!
    @account = accounts(:quentin)
  end
  
  context "Associations" do
    specify "has many devices" do
      @account.should.respond_to(:devices)
    end
    
    specify "has many geofences" do
      @account.should.respond_to(:geofences)
    end
    
    specify "has many landmarks" do
      @account.should.respond_to(:landmarks)
    end
    
    specify "has many alert recipients" do
      @account.should.respond_to(:alert_recipients)
    end
    
    specify "has many tags" do
      @account.should.respond_to(:tags)
    end
    
    specify "has many users" do
      @account.users.should.include(users(:quentin))
    end
    
    specify "has many device profiles" do
      @account.device_profiles.should.include(device_profiles(:quentin))
    end
  end

  context "Validations" do
    specify "valid phone number" do
      @account.save!
      @account.should.be.valid
      
      @account.phone_number = 'asdf'
      @account.should.not.be.valid
      assert @account.errors.on(:phone_number)
    end
  end

  specify "acts as tree" do
    @account.parent.should.be.nil
    @account.children.should.equal [accounts(:aaron)]
    
    accounts(:aaron).parent.should.equal @account
    accounts(:aaron).children.should.equal []
  end
  
  specify "can get the 'today' value" do
    a = accounts(:quentin)
    a.today.should.equal Date.today

    a.update_attribute(:today, Date.parse("10/01/2005"))
    a.today.should.equal Date.parse("10/01/2005")

    a.update_attribute(:today, nil)
    a.today.should.equal Date.today
  end
  
  specify "has a setup helper" do
    @account.setup_status = 3
    @account.should.not.be.setup
    
    @account.setup_status = 0
    @account.should.be.setup
  end
   
  context 'invoice generation' do
    setup do
      @invoice = @account.generate_invoice(Date.today)
    end

    specify 'works' do
      Invoice.should.differ(:count).by(1) do
        @invoice = @account.generate_invoice(Date.today)
      end
      
      @invoice.account.should.equal @account
      @invoice.paid.should.be false
    end

    specify 'generated on date' do
      @invoice.generated_on.should.equal Date.today
    end

    specify 'due at end of month for generated date' do
      @invoice.due_on.should.equal Date.today.end_of_month
    end

    specify 'number of units' do
      @invoice.number_of_units.should.equal @account.trackers.count
    end

    specify 'period start beginning of month' do
      @invoice.period_start.should.equal Date.today.beginning_of_month
    end

    specify 'amount' do
      @invoice.amount.should.equal @account.trackers.count * (@account.monthly_unit_price || 0)
    end
  end 
 
end
