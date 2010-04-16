require 'test_helper'

describe "Groups Helper", ActionView::TestCase do

  tests GroupsHelper

  context "Groups Helper" do
    setup do
      @device_group = device_groups(:north)
    end

    specify "true" do
      true.should.equal true
    end

    specify "empty works" do
      @tree = new_tree(@device_group, :include_parent => true, :root_ol => false, :vehicles => false) do |node, level|
      end

      assert_dom_equal '<li><ol></ol></li>', @tree
    end

    specify "devices attached to groups" do
      @device_group.devices << devices(:quentin_device)

      @tree = new_tree(@device_group, :include_parent => true, :root_ol => false, :vehicles => true) do |node, level|
        node.name
      end
      
      assert_dom_equal '<li>North<ol><li>Quentin\'s Device</li></ol></li>', @tree
    end

    specify "users attached to groups" do
      @device_group.users << users(:quentin)

      @tree = new_tree(@device_group, :include_parent => false, :root_ol => false, :users => true, :vehicles => false) do |node, level|
        node.name
      end

      assert_dom_equal '<li>North<ol><li>Quentin</li></ol></li>', @tree
    end
  end

end
