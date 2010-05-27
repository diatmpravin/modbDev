require 'test_helper'

describe "Invoice", ActiveSupport::TestCase do
  setup do
  end

  specify 'requires an account' do
    i = Invoice.new
    i.amount = 12.00
    i.should.not.be.valid

    i.account = accounts(:quentin)
    i.should.be.valid
  end

  specify 'paid' do
    i = Invoice.new
    i.amount = 12.00

    i.paid?.should.be false
    
    i.amount_paid = 12.00
    i.paid?.should.be true
  end
end
