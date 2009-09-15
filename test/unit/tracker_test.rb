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
          :sim_number => '11112222333344445555')
        @tracker2 = Tracker.create(:status => Tracker::INVENTORY,
          :imei_number => '222233334444555',
          :sim_number => '22223333444455556666')
        @tracker3 = Tracker.create(:status => Tracker::ACTIVE,
          :imei_number => '333344445555666',
          :sim_number => '33334444555566667777')
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
  
  # TEMPORARILY disabled until we resolve this whole "some devices report with
  # the wrong number" deal.
  xspecify "requires an imei number" do
    @device.imei_number = nil
    @device.should.not.be.valid
    @device.errors.on(:imei_number).should.equal("can't be blank")
  end
  
  # TEMPORARILY disabled until we resolve this whole "some devices report with
  # the wrong number" deal.
  xspecify "requires a valid imei number" do
    @device.imei_number = '123456789012345'
    @device.should.be.valid
    
    @device.imei_number = '12345678901234'
    @device.should.not.be.valid
    @device.errors.on(:imei_number).should.equal 'must be 15 digits'
    
    @device.imei_number = '1234567890123456'
    @device.should.not.be.valid
    @device.errors.on(:imei_number).should.equal 'must be 15 digits'
    
    @device.imei_number = '1234abcd90123456789'
    @device.should.not.be.valid
    @device.errors.on(:imei_number).should.equal 'must be 15 digits'
  end
end