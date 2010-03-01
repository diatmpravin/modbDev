require 'test_helper'

describe "Tracker", ActiveSupport::TestCase do
  setup do
    @tracker = trackers(:quentin_tracker)
  end
  
  context "Scopes" do
    context "status scopes" do
      setup do
        @tracker1 = Tracker.create(:status => Tracker::UNKNOWN,
          :imei_number => '111122223333444',
          :sim_number => '11112222333344445555',
          :account => accounts(:quentin))
        @tracker2 = Tracker.create(:status => Tracker::INVENTORY,
          :imei_number => '222233334444555',
          :sim_number => '22223333444455556666',
          :account => accounts(:quentin))
        @tracker3 = Tracker.create(:status => Tracker::ACTIVE,
          :imei_number => '333344445555666',
          :sim_number => '33334444555566667777',
          :account => accounts(:quentin))
      end
      
      specify "unknown trackers" do
        Tracker.unknown.should.include(@tracker1)
        Tracker.unknown.should.not.include(@tracker2)
        Tracker.unknown.should.not.include(@tracker3)
      end    
      
      specify "inventory trackers" do
        Tracker.inventory.should.not.include(@tracker1)
        Tracker.inventory.should.include(@tracker2)
        Tracker.inventory.should.not.include(@tracker3)
      end    
      
      specify "active trackers" do
        Tracker.active.should.not.include(@tracker1)
        Tracker.active.should.not.include(@tracker2)
        Tracker.active.should.include(@tracker3)
      end
    end
  end
  
  specify "has a helper for status text" do
    Tracker.new(:status => 2).status_text.should.equal 'Active'
  end
  
  specify "requires an imei number" do
    t = Tracker.new
    t.should.not.be.valid
    t.errors.on(:imei_number).should.equal("must be 15 digits")
  end

  specify "requires an account" do
    t = Tracker.new
    t.imei_number = '098765432109875'
    t.should.not.be.valid
    
    t.account = accounts(:quentin)
    t.should.be.valid
  end

  specify "requires a valid imei number" do
    t = Tracker.new
    t.account = accounts(:quentin)
    t.imei_number = '12345678901234'
    t.should.not.be.valid
    t.errors.on(:imei_number).should.equal 'must be 15 digits'

    t.imei_number = '098765432109875'
    t.should.be.valid    
    
    t.imei_number = '1234567890123456'
    t.should.not.be.valid
    t.errors.on(:imei_number).should.equal 'must be 15 digits'
    
    t.imei_number = '1234abcd90123456789'
    t.should.not.be.valid
    t.errors.on(:imei_number).should.equal 'must be 15 digits'
  end
end
