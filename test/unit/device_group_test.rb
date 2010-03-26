require 'test_helper'

describe "Device Group", ActiveSupport::TestCase do
  setup do
    DeviceGroup.rebuild!
    @account = accounts(:quentin)
    @north = device_groups(:north)

    Tracker.any_instance.stubs(:async_configure)
  end

  context "Associations" do
    specify "belongs to an account" do
      @north.account.should.equal @account
    end

    specify "has many devices" do
      d = devices(:quentin_device)
      
      @north.devices.should.equal []
      @north.devices << d
      @north.reload
      @north.devices.should.equal [d]
    end
    
    specify "has and belongs to many geofences" do
      @north.geofences.should.equal []
      @north.geofences << geofences(:quentin_geofence)
      @north.reload
      @north.geofences.should.equal [geofences(:quentin_geofence)]
      geofences(:quentin_geofence).device_groups.should.equal [@north]
    end
    
    specify "has and belongs to many landmarks" do
      @north.landmarks.should.equal []
      @north.landmarks << landmarks(:quentin)
      @north.reload
      @north.landmarks.should.equal [landmarks(:quentin)]
      landmarks(:quentin).device_groups.should.equal [@north]
    end
  end
  
  context "Validations" do
    specify "name must be present" do
      @north.name = nil
      @north.should.not.be.valid
      @north.errors.on(:name).should.equal "can't be blank"
      
      @north.name = ''
      @north.should.not.be.valid
      @north.errors.on(:name).should.equal "can't be blank"
      
      @north.name = '1'
      @north.should.be.valid
    end
    
    specify "name must be less than 30 characters" do
      @north.name = '1234567890123456789012345678901'
      @north.should.not.be.valid
      @north.errors.on(:name).should.equal 'is too long (maximum is 30 characters)'
      
      @north.name = '123456789012345678901234567890'
      @north.should.be.valid
    end
  end
  
  context "Destroy" do
    specify "destroys group and nullifies device's group_id" do
      device = devices(:quentin_device)
      
      @north.devices << device
      device.reload.group.should.equal @north
      
      @north.destroy
      device.reload.group.should.be.nil
    end
  end

  context "Nested Set" do
    specify "groups can contain other groups" do
      parent = accounts(:quentin).device_groups.create :name => "parent"
      child1 = parent.children.create(:name => "child1", :account => @account)
      child2 = parent.children.create(:name => "child2", :account => @account)
      sub_child1 = child1.children.create(:name => "sub_child1", :account => @account)

      parent.reload; child1.reload
      parent.descendants.should.include child1
      parent.descendants.should.include child2
      parent.descendants.should.include sub_child1

      child1.children.should.equal [sub_child1]
      child1.descendants.should.equal [sub_child1]

      child2.children.should.equal []
    end

    specify "scoped to account" do
      quentin_parent = accounts(:quentin).device_groups.create :name => "parent"
      aaron_parent = accounts(:aaron).device_groups.create :name => "parent"

      quentin_parent.siblings.should.include device_groups(:north)
      quentin_parent.siblings.should.include device_groups(:south)

      aaron_parent.siblings.should.equal [device_groups(:aaron)]
    end

    specify "destroy_and_rollup moves everything up one level" do
      parent = @account.device_groups.create :name => 'parent'

      group = parent.children.create(:name => 'My group', :account => @account)

      group.devices << Device.generate!
      group.devices << Device.generate!
      group.devices << Device.generate!

      g = group.children.create(:name => 'woot me', :account => @account)

      parent.devices.count.should.equal 0
      
      group.destroy_and_rollup ; parent.reload

      # Group moved up
      parent.children.should.equal [g]

      # Devices moved up
      parent.devices.count.should.equal 3
    end
  end

  context "Grading" do
    setup do
      @north.update_attribute(:grading, {
        :key1 => {:fail => 90, :pass => 30},
        :key2 => {:fail => 10, :pass => 10}
      })
    end

    specify "can know if a value is fail" do
      @north.grade(:key1, 100).should.be DeviceGroup::Grade::FAIL
    end

    specify "can know if a value is warn" do
      @north.grade(:key1, 70).should.be DeviceGroup::Grade::WARN
    end

    specify "can know if a value is pass" do
      @north.grade(:key1, 25).should.be DeviceGroup::Grade::PASS
    end

    specify "gives Pass if no grading defined for key" do
      @north.grade(:unknown, 1200).should.be DeviceGroup::Grade::PASS
    end

    context "Over a range of time" do
      xspecify "takes an average of the value over days before grading" do
        @north.grade(:key2, 100, 10).should.be DeviceGroup::Grade::PASS

        @north.grade(:key1, 120, 2).should.be DeviceGroup::Grade::WARN
      end
    end

    context "Reversed parameters" do
      setup do
        @north.grading.merge!({:mpg => {:fail => 20, :pass => 40}})
        @north.save
      end

      specify "certain parameters are graded in a reverse fashion" do
        @north.grade(:mpg, 30).should.equal DeviceGroup::Grade::WARN

        @north.grade(:mpg, 40).should.equal DeviceGroup::Grade::PASS
        @north.grade(:mpg, 50).should.equal DeviceGroup::Grade::PASS

        @north.grade(:mpg, 20).should.equal DeviceGroup::Grade::FAIL
        @north.grade(:mpg, 10).should.equal DeviceGroup::Grade::FAIL
      end
    end
  end
  
  context "Moving to a new parent during update" do
    specify "works as expected" do
      device_groups(:north).children.length.should.equal 0
      
      # Move to a new device group
      device_groups(:south).update_attributes(:parent_id => device_groups(:north).id)
      device_groups(:north).reload.children.length.should.equal 1
      device_groups(:south).reload.parent.should.equal device_groups(:north)
      
      # Move nowhere
      device_groups(:south).update_attributes(:name => 'Groups R Us')
      device_groups(:north).reload.children.length.should.equal 1
      device_groups(:south).reload.parent.should.equal device_groups(:north)
      
      # Move to root
      device_groups(:south).update_attributes(:parent_id => '')
      device_groups(:north).reload.children.length.should.equal 0
      device_groups(:south).reload.parent.should.equal nil
    end
    
    specify "display failed moves as AR errors, instead of exceptions" do
      parent   = accounts(:quentin).device_groups.create(:name => "parent")
      child    = parent.children.create(:name => "child1", :account => @account)
      subchild = child.children.create(:name => "child2", :account => @account)
      
      # Do a test!
    end
  end
end
