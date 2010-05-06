require 'test_helper'

describe "Geofence", ActiveSupport::TestCase do
  setup do
    DeviceGroup.rebuild!
    
    @account = accounts(:quentin)
    @geofence = geofences(:quentin_geofence)
  end
  
  context "Associations" do
    specify "belongs to an account" do
      @geofence.should.respond_to(:account)
      @geofence.account.should.equal @account
    end
    
    specify "has many device groups" do
      @geofence.device_groups.should.equal []
      @geofence.device_groups << device_groups(:north) << device_groups(:south)
      assert @geofence.reload.device_groups.include?(device_groups(:north))
      assert @geofence.reload.device_groups.include?(device_groups(:south))
    end

    specify "updates associated group delta" do
      device_group = device_groups(:north)
      device_group.delta = false
      device_group.save
      
      device_group.reload.delta.should.equal false
      @geofence.update_attributes(:device_groups => [device_group])
      @geofence.reload.device_groups.first.delta.should.equal true
    end
  end
  
  context "Validations" do
    specify "name must be present" do
      @geofence.name = nil
      @geofence.should.not.be.valid
      @geofence.errors.on(:name).should.equal 'can\'t be blank'
      
      @geofence.name = ''
      @geofence.should.not.be.valid
      @geofence.errors.on(:name).should.equal 'can\'t be blank'
      
      @geofence.name = '1'
      @geofence.should.be.valid
    end
    
    specify "name must be less than 30 characters" do
      @geofence.name = '1234567890123456789012345678901'
      @geofence.should.not.be.valid
      @geofence.errors.on(:name).should.equal 'is too long (maximum is 30 characters)'
      
      @geofence.name = '123456789012345678901234567890'
      @geofence.should.be.valid
    end
    
  end 
  
  context "Serialized coordinates" do
    specify "can get and set coordinates" do
      @geofence.coordinates.should.equal [
        {:latitude => 40.222222, :longitude => -86.333333},
        {:latitude => 40.333333, :longitude => -85.333333}
      ]
      
      @geofence.coordinates[1] = {:latitude => 50.001, :longitude => -86.001}
      @geofence.save
      
      @geofence.reload.coordinates.should.equal [
        {:latitude => 40.222222, :longitude => -86.333333},
        {:latitude => 50.001, :longitude => -86.001}
      ]
    end
    
    specify "can use the coordinates array immediately on a new geofence" do
      geofence = @account.geofences.new(:name => 'Test')
      geofence.coordinates << {:latitude => 10.05, :longitude => 10.05}
      geofence.should.save
      geofence.coordinates.should.equal [
        {:latitude => 10.05, :longitude => 10.05}
      ]
    end
    
    specify "coordinates are always floats" do
      @geofence.coordinates.clear
      @geofence.coordinates << {:latitude => "50.001", :longitude => "-86.001"}
      @geofence.save
      
      @geofence.reload.coordinates.should.equal [
        {:latitude => 50.001, :longitude => -86.001}
      ]
    end
  end
  
  context "Coordinates as text" do
    specify "can return coordinates as a comma-separated list" do
      @geofence.coordinates.should.equal [
        {:latitude => 40.222222, :longitude => -86.333333},
        {:latitude => 40.333333, :longitude => -85.333333}
      ]
      
      @geofence.coordinates_text.should.equal '40.222222,-86.333333,40.333333,-85.333333'
    end
    
    specify "can set coordinates with a comma-separated list" do
      @geofence.update_attributes(
        :coordinates_text => '45.3,46.7,20.7,20.4'
      )
      
      @geofence.reload.coordinates.should.equal [
        {:latitude => 45.3, :longitude => 46.7},
        {:latitude => 20.7, :longitude => 20.4}
      ]
    end
  end
  
  specify "protects appropriate attributes" do
    geofence = Geofence.new(:account_id => 7)
    geofence.account_id.should.be.nil
    
    geofence = Geofence.new(:account => @account)
    geofence.account_id.should.equal @account.id
  end
  
  specify "allows device_group_ids=, but enforces account ownership" do
    @geofence.update_attributes(:device_group_ids => [])
    @geofence.device_groups.should.be.empty
    
    @geofence.update_attributes(:device_group_ids => [device_groups(:north).id])
    @geofence.device_groups.should.include(device_groups(:north))
    
    bad = accounts(:aaron).device_groups.create!(:name => 'Aaron Group')
    should.raise(ActiveRecord::RecordNotFound) do
      @geofence.update_attributes(:device_group_ids => [bad.id])
    end
  end
  
  specify "when setting device groups, weeds out groups already included in the tree" do
    child = @account.device_groups.create(:name => 'North Child')
    child.move_to_child_of(device_groups(:north))
    
    @geofence.update_attributes(:device_groups => [child, device_groups(:south)])
    assert @geofence.device_groups.include?(device_groups(:south))
    assert @geofence.device_groups.include?(child)
    
    @geofence.update_attributes(:device_groups => [device_groups(:north), device_groups(:south), child])
    assert @geofence.device_groups.include?(device_groups(:north))
    assert @geofence.device_groups.include?(device_groups(:south))
    assert !@geofence.device_groups.include?(child)
  end
  
  context "Testing if a point is within a geofence" do
    specify "inside rectangular geofences" do
      @geofence.geofence_type = Geofence::Type::RECTANGLE
      @geofence.coordinates = [
        {:latitude => 80.0, :longitude => -40.0},
        {:latitude => 86.0, :longitude => -35.0}
      ]
      
      point = Point.new(:latitude => 81, :longitude => -38)
      assert @geofence.contain?(point)
      
      point = Point.new(:latitude => 79, :longitude => -38)
      assert !@geofence.contain?(point)
      
      point = Point.new(:latitude => 83, :longitude => -33)
      assert !@geofence.contain?(point)
      
      point = Point.new(:latitude => 86, :longitude => -35)
      assert @geofence.contain?(point)
    end
    
    specify "inside elliptical geofences" do
      # These tests were created using real coordinates captured from portal
      @geofence.geofence_type = Geofence::Type::ELLIPSE
      @geofence.coordinates = [
        {:latitude => 42.86816, :longitude => -85.662561},
        {:latitude => 42.829657, :longitude => -85.554112}
      ]
      
      point = Point.new(:latitude => 42.84368, :longitude => -85.558006)
      assert @geofence.contain?(point)
      
      point = Point.new(:latitude => 42.864357, :longitude => -85.618522)
      assert @geofence.contain?(point)
      
      point = Point.new(:latitude => 42.832746, :longitude => -85.565496)
      assert !@geofence.contain?(point)
      
      point = Point.new(:latitude => 42.862694, :longitude => -85.651476)
      assert !@geofence.contain?(point)
    end
    
    specify "inside polygonal geofences" do
      @geofence.geofence_type = Geofence::Type::POLYGON
      @geofence.coordinates = [
        {:latitude => 50, :longitude => 50},    # Tests using this shape:
        {:latitude => 60, :longitude => 50},    # 
        {:latitude => 60, :longitude => 55},    #    xxxxxxxxxxxxxxxxx
        {:latitude => 55, :longitude => 55},    #    xxxxxxxxxxxxxxxxx
        {:latitude => 55, :longitude => 60},    #    xxxxx       xxxxx
        {:latitude => 60, :longitude => 65},    #    xxxxx         xxx
        {:latitude => 50, :longitude => 65}     #    xxxxx           x
      ]
      
      point = Point.new(:latitude => 60, :longitude => 65)
      assert !@geofence.contain?(point)
      
      point = Point.new(:latitude => 59.99, :longitude => 65)
      assert @geofence.contain?(point)
      
      point = Point.new(:latitude => 60, :longitude => 55)
      assert @geofence.contain?(point)
      
      point = Point.new(:latitude => 56, :longitude => 56)
      assert !@geofence.contain?(point)
      
      point = Point.new(:latitude => 60, :longitude => 60)
      assert !@geofence.contain?(point)
      
      point = Point.new(:latitude => 55, :longitude => 57.5)
      assert @geofence.contain?(point)
    end
    
    specify "invalid fence type always returns false" do
      @geofence.geofence_type = -1
      @geofence.coordinates = [
        {:latitude => 80.0, :longitude => -40.0},
        {:latitude => 86.0, :longitude => -35.0}
      ]
      
      point = Point.new(:latitude => 81, :longitude => -38)
      assert !@geofence.contain?(point)
    end
  end
end
