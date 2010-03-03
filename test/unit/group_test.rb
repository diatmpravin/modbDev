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
end
