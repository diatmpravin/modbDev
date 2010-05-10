require 'test_helper'

describe "Report Card Helper", ActionView::TestCase do

  tests ReportCardHelper

  context "Report Card Helper" do
    setup do
    end

    specify 'true' do
      true.should.equal true
    end

    specify 'can drag' do
      users(:quentin).update_attributes(:roles => [User::Role::ADMIN])

      can_drag(users(:quentin)).should.equal ''
    end

    specify 'cannot drag' do
      users(:quentin).update_attributes(:roles => [User::Role::GEOFENCE])

      can_drag(users(:quentin)).should.equal 'undraggable'
    end

  end

end
