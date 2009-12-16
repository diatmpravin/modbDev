require 'test_helper'

describe "Group", ActiveSupport::TestCase do

  setup do
    @north = groups(:north)
  end

  specify "belongs to an account" do
    groups(:north).account.should.equal accounts(:quentin)
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
      Group.of_devices.should.equal [groups(:north), groups(:south)]
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
      parent = Group.create :name => "parent"
      child1 = parent.children.create :name => "child1"
      child2 = parent.children.create :name => "child2"
      sub_child1 = child1.children.create :name => "sub_child1"

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

      aaron_parent.siblings.should.equal []
    end

    xspecify "deleting group moves everything up one level" do
      Group.destroy_all

      parent = accounts(:quentin).groups.create :name => "parent", :of => "Device"

      group = parent.children.create :name => "My group", :of => "Device", 
        :account_id => accounts(:quentin).id

      group.devices << Device.generate!
      group.devices << Device.generate!
      group.devices << Device.generate!

      g = group.children.create :name => "woot me", :of => "Device",
        :account_id => accounts(:quentin).id

      parent.devices.count.should.equal 0

      group.destroy; parent.reload

      # Group moved up
      parent.children.should.equal [g]

      # Devices moved up
      parent.devices.count.should.equal 3
    end

  end

end
