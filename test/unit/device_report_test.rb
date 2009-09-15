require 'test_helper'

describe "Device Report", ActiveSupport::TestCase do
  specify "ignores improperly formatted reports" do
    report = DeviceReport.parse('12345,12345,12345')
    report.should.be.nil
  end
  
  # Location reports pre-1A firmware
  specify "handles a backward-compatible location report correctly" do
    report = DeviceReport.parse('$$12345678901234567890,4001,2009/02/17,12:18:54,33.64512,-84.44697,312.1,31,0,1,866,218.0,9,1.6,21##')
    
    report.should.equal({
      :imei => '12345678901234567890',
      :event => '4001',
      :date => '2009/02/17',
      :time => '12:18:54',
      :latitude => '33.64512',
      :longitude => '-84.44697',
      :altitude => '312.1',
      :speed => '31',
      :accelerating => '0',
      :decelerating => '1',
      :rpm => '866',
      :heading => '218.0',
      :satellites => '9',
      :hdop => '1.6',
      :miles => '21'
    })
  end
  
  # Location reports from new firmware
  specify "handles a location report correctly" do
    report = DeviceReport.parse('$$12345678901234567890,4001,2009/02/17,12:18:54,33.64512,-84.44697,312.1,31,0,1,866,218.0,9,1.6,21,13.1,14.3,12,1##')
    
    report.should.equal({
      :imei => '12345678901234567890',
      :event => '4001',
      :date => '2009/02/17',
      :time => '12:18:54',
      :latitude => '33.64512',
      :longitude => '-84.44697',
      :altitude => '312.1',
      :speed => '31',
      :accelerating => '0',
      :decelerating => '1',
      :rpm => '866',
      :heading => '218.0',
      :satellites => '9',
      :hdop => '1.6',
      :miles => '21',
      :mpg => '13.1',
      :battery => '14.3',
      :signal => '12',
      :gps => '1'
    })
  end
  
  specify "handles a heartbeat report correctly" do
    report = DeviceReport.parse('$$12345678901234567890,4006,2009/02/17,12:18:54,33.64512,-84.44697,312.1,31,0,1,866,218.0,9,1.6,21,13.1,14.3,12,1,S001-1111A,0088,FacDflt,1G1G1G1G1G1G1G##')
    
    report.should.equal({
      :imei => '12345678901234567890',
      :event => '4006',
      :date => '2009/02/17',
      :time => '12:18:54',
      :latitude => '33.64512',
      :longitude => '-84.44697',
      :altitude => '312.1',
      :speed => '31',
      :accelerating => '0',
      :decelerating => '1',
      :rpm => '866',
      :heading => '218.0',
      :satellites => '9',
      :hdop => '1.6',
      :miles => '21',
      :mpg => '13.1',
      :battery => '14.3',
      :signal => '12',
      :gps => '1',
      :fw_version => 'S001-1111A',
      :obd_fw_version => '0088',
      :profile => 'FacDflt',
      :vin => '1G1G1G1G1G1G1G'
    })
  end
  
  specify "handles a reset report correctly" do
    report = DeviceReport.parse('$$12345678901234567890,6015,2009/02/17,12:18:54,33.64512,-84.44697,312.1,31,0,1,866,218.0,9,1.6,21,13.1,14.3,12,1,S001-1111A,0088,FacDflt,1G1G1G1G1G1G1G##')
    
    report.should.equal({
      :imei => '12345678901234567890',
      :event => '6015',
      :date => '2009/02/17',
      :time => '12:18:54',
      :latitude => '33.64512',
      :longitude => '-84.44697',
      :altitude => '312.1',
      :speed => '31',
      :accelerating => '0',
      :decelerating => '1',
      :rpm => '866',
      :heading => '218.0',
      :satellites => '9',
      :hdop => '1.6',
      :miles => '21',
      :mpg => '13.1',
      :battery => '14.3',
      :signal => '12',
      :gps => '1',
      :fw_version => 'S001-1111A',
      :obd_fw_version => '0088',
      :profile => 'FacDflt',
      :vin => '1G1G1G1G1G1G1G'
    })
  end
end
