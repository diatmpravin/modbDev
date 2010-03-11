require 'test_helper'

describe "Group", ActiveSupport::TestCase do
  setup do
    Group.rebuild!
    @account = accounts(:quentin)
    @north = groups(:north)
  end

  specify "belongs to an account" do
    groups(:north).account.should.equal @account
  end

  context "has and belongs to many" do
    specify "devices" do
      d = devices(:quentin_device)

      @north.devices.should.equal []

      @north.devices << d
      @north.reload

      @north.devices.should.equal [d]
    end
  end

  context "Scopes" do
    specify "of_devices" do
      list = Group.of_devices
      list.length.should.equal 3
      assert list.include?(groups(:north))
      assert list.include?(groups(:south))
      assert list.include?(groups(:aaron))
      
      accounts(:aaron).groups.of_devices.should.equal [groups(:aaron)]
    end
  end

  context "Destroy" do
    setup do
      @group = groups(:north)
      @group.devices << devices(:quentin_device)
    end

    specify "destruction of group only removes group and linking, leaves actual items" do
      @group.destroy
      assert Device.exists?(:name => "Quentin's Device")
    end
  end

  context "Nested Set" do
    specify "groups can contain other groups" do
      parent = accounts(:quentin).groups.create :name => "parent"
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
      quentin_parent = accounts(:quentin).groups.create :name => "parent"
      aaron_parent = accounts(:aaron).groups.create :name => "parent"

      quentin_parent.siblings.should.include groups(:north)
      quentin_parent.siblings.should.include groups(:south)
      quentin_parent.siblings.should.include groups(:west)

      aaron_parent.siblings.should.equal [groups(:aaron)]
    end

    specify "destroy_and_rollup moves everything up one level" do
      parent = @account.groups.create :name => 'parent', :of => 'Device'

      group = parent.children.create(:name => 'My group', :of => 'Device',
        :account => @account)

      group.devices << Device.generate!
      group.devices << Device.generate!
      group.devices << Device.generate!

      g = group.children.create(:name => 'woot me', :of => 'Device',
        :account => @account)

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
      @north.grade(:key1, 100).should.be Group::Grade::FAIL
    end

    specify "can know if a value is warn" do
      @north.grade(:key1, 70).should.be Group::Grade::WARN
    end

    specify "can know if a value is pass" do
      @north.grade(:key1, 25).should.be Group::Grade::PASS
    end

    specify "gives Pass if no grading defined for key" do
      @north.grade(:unknown, 1200).should.be Group::Grade::PASS
    end

    context "Over a range of time" do

      specify "takes an average of the value over days before grading" do
        @north.grade(:key2, 100, 10).should.be Group::Grade::PASS

        @north.grade(:key1, 120, 2).should.be Group::Grade::WARN
      end

    end

    context "Reversed parameters" do

      setup do
        @north.grading.merge!({:mpg => {:fail => 20, :pass => 40}})
        @north.save
      end

      specify "certain parameters are graded in a reverse fashion" do
        @north.grade(:mpg, 30).should.equal Group::Grade::WARN

        @north.grade(:mpg, 40).should.equal Group::Grade::PASS
        @north.grade(:mpg, 50).should.equal Group::Grade::PASS

        @north.grade(:mpg, 20).should.equal Group::Grade::FAIL
        @north.grade(:mpg, 10).should.equal Group::Grade::FAIL
      end

    end

  end
end
