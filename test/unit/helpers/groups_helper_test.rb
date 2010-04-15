require 'test_helper'
require 'action_view/test_case'

describe "Groups Helper", ActionView::TestCase do

  setup do
    class << self
      tests GroupsHelper
      include helper_class
    end

    setup_with_controller
  end

  context "Groups Helper" do
    specify "true" do
      true.should.equal true
    end

    specify "empty works" do
      #self.class.send(:include, GroupsHelper)

      @device_group = device_groups(:north)
      @tree = new_tree(@device_group, :include_parent => true, :root_ol => false, :vehicles => false) do |node, level|
      end

      assert_dom_equal '<li><ol></ol></li>', @tree
    end

    specify "devices attached to groups" do
      @device_group = device_groups(:north)
      @device_group.devices << devices(:quentin_device)

      @tree = new_tree(@device_group, :include_parent => true, :root_ol => false, :vehicles => true) do |node, level|
        node.name
      end
      
      assert_dom_equal '<li>North<ol><li>Quentin\'s Device</li></ol></li>', @tree
    end
  end

end
