require 'test_helper'

describe "Report", ActiveSupport::TestCase do
  setup do
    @account = accounts(:quentin)
    @devices = @account.devices
  end
  
  context "Vehicle Summary Report" do
    specify "works" do
      report = Report.new(@account, {
        :type => 0,
        :devices => @devices,
        :range => {
          :type => 7,
          :start => '02/01/2009',
          :end => '02/10/2009',
        }
      })
      
      report.data[0][:name].should.equal 'Quentin\'s Device'
      report.data[0][:miles].should.equal 6
      report.data[0][:duration].should.equal 900.0
    end
    
    specify "errors on missing dates" do
      report = Report.new(@account, {
        :type => 0,
        :devices => @devices,
        :range => {
          :type => 7
        }
      })
      
      report.should.not.be.valid
      report.errors.first.should.equal 'You must specify valid start and end dates'
    end
    
    specify "requires at least one vehicle" do
      report = Report.new(@account, {
        :type => 0,
        :devices => [],
        :range => {
          :type => 7,
          :start => '02/01/2009',
          :end => '02/10/2009'
        }
      })
      
      report.should.not.be.valid
      report.errors.first.should.equal 'You must choose one or more vehicles to run this report'
    end
  end
  
  context "Daily Summary Report" do
    specify "works" do
      report = Report.new(@account, {
        :type => 1,
        :devices => @devices,
        :range => {
          :type => 7,
          :start => '02/01/2009',
          :end => '02/10/2009'
        }
      })
      
      report.data[0][:date].should.equal Date.parse('02/01/2009')
      report.data[0][:miles].should.equal 0
      report.data[0][:duration].should.equal 0
      
      report.data[4][:date].should.equal Date.parse('02/05/2009')
      report.data[4][:miles].should.equal 6
      report.data[4][:duration].should.equal 900
    end
    
    specify "errors on missing dates" do
      report = Report.new(@account, {
        :type => 1,
        :devices => @devices,
        :range => {
          :type => 7
        }
      })
      
      report.should.not.be.valid
      report.errors.first.should.equal 'You must specify valid start and end dates'
    end
    
    specify "errors on broken dates" do
      report = Report.new(@account, {
        :type => 0,
        :devices => @devices,
        :range => {
          :type => 7,
          :start => 'blargh',
          :end => '02/30/what'
        }
      })
      
      report.should.not.be.valid
      report.errors.first.should.equal 'You must specify valid start and end dates'
    end
    
    specify "requires only one vehicle" do
      report = Report.new(@account, {
        :type => 1,
        :devices => [],
        :range => {
          :type => 7,
          :start => '02/01/2009',
          :end => '02/10/2009'
        }
      })
      
      report.run.should.be.nil
      report.errors.first.should.equal 'You must choose one vehicle to run this report'
      
      #report.error.should.equal 'You must choose one vehicle to run this report'
    end
  end
end
