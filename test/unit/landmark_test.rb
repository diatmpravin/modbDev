require 'test_helper'

describe "Landmark", ActiveSupport::TestCase do
  setup do
    @account = accounts(:quentin)
    @device = devices(:quentin_device)
    @landmark = landmarks(:quentin)
  end
  
  context "Associations" do
    specify "belongs to an account" do
      @landmark.should.respond_to(:account)
      @landmark.account.should.equal @account
    end
    
    specify "has many device groups" do
      @landmark.device_groups.should.equal []
      @landmark.device_groups << device_groups(:north) << device_groups(:south)
      assert @landmark.reload.device_groups.include?(device_groups(:north))
      assert @landmark.reload.device_groups.include?(device_groups(:south))
    end
  end
  
  context "Validations" do
    specify "name must be present" do
      @landmark.name = nil
      @landmark.should.not.be.valid
      @landmark.errors.on(:name).should.equal 'can\'t be blank'
      
      @landmark.name = ''
      @landmark.should.not.be.valid
      @landmark.errors.on(:name).should.equal 'can\'t be blank'
      
      @landmark.name = '1'
      @landmark.should.be.valid
    end
    
    specify "name must be less than 30 characters" do
      @landmark.name = '1234567890123456789012345678901'
      @landmark.should.not.be.valid
      @landmark.errors.on(:name).should.equal 'is too long (maximum is 30 characters)'
      
      @landmark.name = '123456789012345678901234567890'
      @landmark.should.be.valid
    end
    
    specify "latitude must be present" do
      @landmark.latitude = nil
      @landmark.should.not.be.valid
      
      @landmark.latitude = 42.0
      @landmark.should.be.valid
    end
    
    specify "latitude must be numeric" do
      @landmark.latitude = 'abc123'
      @landmark.should.not.be.valid
      
      @landmark.latitude = '-4.2'
      @landmark.should.be.valid
    end
    
    specify "longitude must be present" do
      @landmark.longitude = nil
      @landmark.should.not.be.valid
      
      @landmark.longitude = -86.0
      @landmark.should.be.valid
    end
    
    specify "longitude must be numeric" do
      @landmark.longitude = 'abc123'
      @landmark.should.not.be.valid
      
      @landmark.longitude = '-8.6'
      @landmark.should.be.valid
    end
  end
  
  specify "protects appropriate attributes" do
    landmark = Landmark.new(:account_id => 7)
    landmark.account_id.should.be.nil
    
    landmark = Landmark.new(:account => @account)
    landmark.account_id.should.equal @account.id
  end
  
  specify "knows whether a point is at this location" do
    points = [
      Point.new(:latitude => 40.223, :longitude => -86.33333),
      Point.new(:latitude => 40.2232, :longitude => -86.33333),
      Point.new(:latitude => 40.22229, :longitude => -86.3345),
      Point.new(:latitude => 40.22229, :longitude => -86.3347)
    ]
    
    # Sanity check
    @landmark.radius.should.equal 100
    @landmark.latitude.should.equal BigDecimal.new('40.22222')
    @landmark.longitude.should.equal BigDecimal.new('-86.33333')
    
    # Test
    assert @landmark.contain?(points[0])
    assert !@landmark.contain?(points[1])
    assert @landmark.contain?(points[2])
    assert !@landmark.contain?(points[3])
  end  
end
