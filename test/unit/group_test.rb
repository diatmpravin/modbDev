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

  end

end
