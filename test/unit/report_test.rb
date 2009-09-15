require 'test_helper'

describe "Report", ActiveSupport::TestCase do
  setup do
    @account = accounts(:quentin)
    @devices = @account.devices
  end
  
  context "Creating and configuring a report" do
    specify "can create a report" do
      report = Report.new(@account)
      
      report.account.should.equal @account
    end
    
    specify "can create a report with options" do
      report = Report.new(@account, :report_type => 2, :range_type => 0)
      
      report.report_type.should.equal 2
      report.range_type.should.equal 0
    end
  end
  
  context "Vehicle Summary Report" do
    specify "works" do
      report = Report.new(@account, {
        :start_date => '02/01/2009',
        :end_date => '02/10/2009',
        :devices => @devices.map(&:id),
        :report_type => 0,
        :range_type => 0
      })
      
      report.data[0][:name].should.equal 'Quentin\'s Device'
      report.data[0][:miles].should.equal 6
      report.data[0][:duration].should.equal '00:15'
    end
    
    specify "errors on missing dates" do
      report = Report.new(@account, {
        :devices => @devices.map(&:id),
        :report_type => 0,
        :range_type => 0
      })
      
      report.run
      report.error.should.equal 'You must specify valid start and end dates'
    end
    
    specify "requires at least one vehicle" do
      report = Report.new(@account, {
        :start_date => '02/01/2009',
        :end_date => '02/10/2009',
        :report_type => 0,
        :range_type => 0
      })
      
      report.run
      report.error.should.equal 'You must choose one or more vehicles to run this report'
    end
  end
  
  context "Daily Summary Report" do
    specify "works" do
      report = Report.new(@account, {
        :start_date => '02/01/2009',
        :end_date => '02/10/2009',
        :devices => @devices.map(&:id),
        :report_type => 1,
        :range_type => 0
      })
      
      report.data[0][:date].should.equal Date.parse('02/01/2009')
      report.data[0][:miles].should.equal 0
      report.data[0][:duration].should.equal '00:00'
      
      report.data[4][:date].should.equal Date.parse('02/05/2009')
      report.data[4][:miles].should.equal 6
      report.data[4][:duration].should.equal '00:15'
    end
    
    specify "errors on missing dates" do
      report = Report.new(@account, {
        :devices => @devices.map(&:id),
        :report_type => 1,
        :range_type => 0
      })
      
      report.run
      report.error.should.equal 'You must specify valid start and end dates'
    end
    
    specify "errors on broken dates" do
      report = Report.new(@account, {
        :start_date => 'blargh',
        :end_date => '02/30/what',
        :devices => @devices.map(&:id),
        :report_type => 1,
        :range_type => 0
      })
      
      report.run
      report.error.should.equal 'You must specify valid start and end dates'
    end
    
    specify "requires only one vehicle" do
      report = Report.new(@account, {
        :start_date => '02/01/2009',
        :end_date => '02/10/2009',
        :report_type => 1,
        :range_type => 0
      })
      
      report.run
      report.error.should.equal 'You must choose one vehicle to run this report'
      
      report.devices = ['1','2']
      report.run
      report.error.should.equal 'You must choose one vehicle to run this report'
    end
  end
  
  context "Event Detail Report" do
    specify "works" do
      report = Report.new(@account, {
        :start_date => '02/01/2009',
        :end_date => '02/10/2009',
        :devices => @devices.map(&:id),
        :report_type => 2,
        :range_type => 0
      })
      
      report.data[0][:date].should.equal '02/05/2009'
      report.data[0][:time].should.equal '08:00 AM UTC'
      report.data[0][:device].should.equal 'Quentin\'s Device'
      report.data[0][:text].should.equal 'Enter Boundary'
    end
    
    specify "errors on missing dates" do
      report = Report.new(@account, {
        :devices => @devices.map(&:id),
        :report_type => 2,
        :range_type => 0
      })
      
      report.run
      report.error.should.equal 'You must specify valid start and end dates'
    end
    
    specify "requires at least one vehicle" do
      report = Report.new(@account, {
        :start_date => '02/01/2009',
        :end_date => '02/10/2009',
        :report_type => 2,
        :range_type => 0
      })
      
      report.run
      report.error.should.equal 'You must choose one or more vehicles to run this report'
    end
  end
  
  context "Singleton helpers" do
    specify "provides report type options" do
      o = Report.type_options
      o.invert.should.equal Report::REPORT_TYPES
    end
    
    specify "provides range type options" do
      o = Report.range_options
      o.invert.should.equal Report::RANGE_TYPES
    end
  end
end
