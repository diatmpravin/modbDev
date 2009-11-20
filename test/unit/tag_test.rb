require 'test_helper'

describe "Tag", ActiveSupport::TestCase do
  setup do
    @account = accounts(:quentin)
    @tag = tags(:quentin_tag)
    @trip = trips(:quentin_trip)
    @device = devices(:quentin_device)
  end
  
  context "Associations" do
    specify "belongs to an account" do
      @tag.should.respond_to(:account)
      @tag.account.should.equal accounts(:quentin)
    end
    
    specify "has many trips" do
      @tag.trips.should.include @trip
    end
    
    specify "has many devices" do
      @tag.devices.should.include @device
    end
  end
  
  context "Validations" do
    specify "requires name" do
      @tag.should.be.valid
      
      @tag.name = nil
      @tag.should.not.be.valid
      @tag.errors.on(:name).should.equal 'can\'t be blank'
      
      @tag.name = ''
      @tag.should.not.be.valid
      @tag.errors.on(:name).should.equal 'can\'t be blank'
    end
    
    specify "requires name <= 30 characters" do
      @tag.name = '123456789012345678901234567890'
      @tag.should.be.valid
      
      @tag.name = '1234567890123456789012345678901'
      @tag.should.not.be.valid
      @tag.errors.on(:name).should.equal 'is too long (maximum is 30 characters)'
    end
    
    specify "enforces uniqueness of name within an account" do
      tag = @account.tags.create(:name => 'Brand New')
      tag.should.be.valid
      
      tag = @account.tags.create(:name => 'Brand New')
      tag.should.not.be.valid
      tag.errors.on(:name).should.equal 'has already been taken'
      
      tag = accounts(:aaron).tags.create(:name => 'Brand New')
      tag.should.be.valid
    end
  end
  
  context "Scopes" do
    context "for()" do
      specify "excludes tags already on a given object" do
        @account.tags.should.include(@tag)
        @trip.tags.should.include(@tag)
        
        @account.tags.for(@trip).should.not.include(@tag)
        @account.tags.for(@device).should.not.include(@tag)
      end
      
      specify "excludes nothing if the object is new" do
        @account.tags.for(Trip.new).should.include(@tag)
        @account.tags.for(Device.new).should.include(@tag)
      end
    end
  end
  
  specify "protects appropriate attributes" do
    tag = Tag.new(:name => 'Tag', :account_id => 7)
    tag.account_id.should.be.nil
    
    tag = Tag.new(:name => 'Tag', :account => accounts(:quentin))
    tag.account_id.should.equal accounts(:quentin).id
  end
end
