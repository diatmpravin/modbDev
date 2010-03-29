require 'test_helper'

describe "Group Report Card Test", ActiveSupport::TestCase do
  setup do
    DeviceGroup.rebuild!
    Tracker.any_instance.stubs(:async_configure)

    @account = accounts(:quentin)
    @user = users(:quentin)
    @north = device_groups(:north)
    
    @quentin_device = devices(:quentin_device)
    @north.devices << @quentin_device

    @second_device = Device.generate!
    @north.devices << @second_device

    t = @quentin_device.trips.create
    l = t.legs.create
    @point0 = l.points.create(
      :event => DeviceReport::Event::PERIODIC_IGNITION_ON, :latitude => 33.64512, :longitude => -84.44697,
      :occurred_at => Time.parse("01/01/2009 01:00:00 AM EST"), :miles => 100,
      :device => @quentin_device)
    @point1 = l.points.create(
      :event => DeviceReport::Event::PERIODIC_IGNITION_ON, :latitude => 33.64512, :longitude => -84.44697,
      :occurred_at => Time.parse("01/01/2009 11:30:00 AM EST"), :miles => 100,
      :device => @quentin_device)
    @point2 = l.points.create(
      :event => DeviceReport::Event::PERIODIC_IGNITION_ON, :latitude => 33.64512, :longitude => -84.44697,
      :occurred_at => Time.parse("01/01/2009 11:50:30 AM EST"), :miles => 200,
      :device => @quentin_device)
    @point3 = l.points.create(
      :event => DeviceReport::Event::PERIODIC_IGNITION_ON, :latitude => 33.64512, :longitude => -84.44697,
      :occurred_at => Time.parse("01/01/2009 12:30:00 PM EST"), :miles => 300,
      :device => @quentin_device)
    @point4 = l.points.create(
      :event => DeviceReport::Event::PERIODIC_IGNITION_OFF, :latitude => 33.64512, :longitude => -84.44697,
      :occurred_at => Time.parse("01/01/2009 11:29:59 PM EST"), :miles => 300,
      :device => @quentin_device)
      
    @quentin_device.calculate_data_for(Date.parse("01/01/2009"))

    t = @second_device.trips.create
    l = t.legs.create
    l.points.create(
      :event => DeviceReport::Event::PERIODIC_IGNITION_ON, :latitude => 33.64512, :longitude => -84.44697,
      :occurred_at => Time.parse("01/02/2009 02:00:00 AM EST"), :miles => 300,
      :device => @second_device)
    l.points.create(
      :event => DeviceReport::Event::PERIODIC_IGNITION_OFF, :latitude => 33.64512, :longitude => -84.44697,
      :occurred_at => Time.parse("01/02/2009 11:30:00 AM EST"), :miles => 400,
      :device => @second_device)
   
    @second_device.calculate_data_for(Date.parse("01/02/2009")) 
  end

  context "run" do
    specify "works" do

      range_type = {
        :type => Report::DateRange::CUSTOM,
        :start => '01/01/2009',
        :end => '01/10/2009',
      }
      
      grc = GroupReportCard.new(@user, :group => @north, :range => range_type)

      rc = grc.run

      rc.should.not.be.nil
      rc[:first_start].should.be.close 5400, 0.001
    end

    specify "grades" do
      @north.update_attribute(:grading, {
        :first_start => {:fail => 8000, :pass => 4000},
        :mpg => {:fail => 10, :pass => 20}
      })
      
      range_type = {
        :type => Report::DateRange::CUSTOM,
        :start => '01/01/2009',
        :end => '01/10/2009'
      }
      
      grc = GroupReportCard.new(@user, :group => @north, :range => range_type)

      rc = grc.run

      rc.should.not.be.nil
      rc[:report_card][:first_start].should.equal "warn"
      rc[:report_card][:mpg].should.equal "fail"
    end
  end
end
