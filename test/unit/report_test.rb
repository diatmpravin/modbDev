require 'test_helper'

describe "Report", ActiveSupport::TestCase do
  setup do
    @user = users(:quentin)
    @devices = @user.devices
  end

  context "All Reports" do
    context "Date Ranges" do
      specify "Custom: start date must be < end date" do
        report = Report.new(@user, {
          :devices => @devices,
          :range => {
            :type => Report::DateRange::CUSTOM,
            :start => '02/10/2009',
            :end => '02/01/2009',
          }
        })

        report.should.not.be.valid
        report.errors.should.include "Start date must be earlier or equal to end date"
      end

      specify "This Week should include all 7 days" do
        report = Report.new(@user, {
          :devices => @devices,
          :range => {
            :type => Report::DateRange::THIS_WEEK
          }
        })

        report.range.start.should.equal Date.today.beginning_of_week
        report.range.end.should.equal Date.today.end_of_week
      end

      specify "This Month should include all days of the month" do
        report = Report.new(@user, {
          :devices => @devices,
          :range => {
            :type => Report::DateRange::THIS_MONTH
          }
        })

        report.range.start.should.equal Date.today.beginning_of_month
        report.range.end.should.equal Date.today.end_of_month
      end

      specify "This Year should include the whole year" do
        report = Report.new(@user, {
          :devices => @devices,
          :range => {
            :type => Report::DateRange::THIS_YEAR
          }
        })

        report.range.start.should.equal Date.today.beginning_of_year
        report.range.end.should.equal Date.today.end_of_year
      end
    end
  end
  
  context "Vehicle Summary Report" do
    specify "works" do
      report = VehicleSummaryReport.new(@user, {
        :devices => @devices,
        :range => {
          :type => Report::DateRange::CUSTOM,
          :start => '02/01/2009',
          :end => '02/10/2009',
        }
      })
      report.run
      
      report.data[0][:name].should.equal 'Quentin\'s Device'
      report.data[0][:miles].should.equal 6
      report.data[0][:duration].should.equal 900.0
    end
    
    specify "errors on missing dates" do
      report = Report.new(@user, {
        :devices => @devices,
        :range => {
          :type => Report::DateRange::CUSTOM
        }
      })
      
      report.should.not.be.valid
      report.errors.should.include 'You must specify valid start and end dates'
    end
    
    specify "requires at least one vehicle" do
      report = VehicleSummaryReport.new(@user, {
        :devices => [],
        :range => {
          :type => Report::DateRange::CUSTOM,
          :start => '02/01/2009',
          :end => '02/10/2009'
        }
      })
      report.validate
      
      report.should.not.be.valid
      report.errors.should.include 'You must choose one or more vehicles to run this report'
    end
  end
  
  context "Daily Summary Report" do
    specify "works" do
      report = DailySummaryReport.new(@user, {
        :devices => @devices,
        :range => {
          :type => Report::DateRange::CUSTOM,
          :start => '02/01/2009',
          :end => '02/10/2009'
        }
      })
      report.validate
      report.should.be.valid

      report.run
      
      report.data[0][:date].should.equal Date.parse('02/01/2009')
      report.data[0][:miles].should.equal 0
      report.data[0][:duration].should.equal 0
      
      report.data[4][:date].should.equal Date.parse('02/05/2009')
      report.data[4][:miles].should.equal 6
      report.data[4][:duration].should.equal 900
    end
    
    specify "errors on missing dates" do
      report = DailySummaryReport.new(@user, {
        :devices => @devices,
        :range => {
          :type => Report::DateRange::CUSTOM
        }
      })
      report.validate
      
      report.should.not.be.valid
      report.errors.should.include 'You must specify valid start and end dates'
    end
    
    specify "errors on broken dates" do
      report = DailySummaryReport.new(@user, {
        :devices => @devices,
        :range => {
          :type => Report::DateRange::CUSTOM,
          :start => 'blargh',
          :end => '02/30/what'
        }
      })
      report.validate
      
      report.should.not.be.valid
      report.errors.should.include 'You must specify valid start and end dates'
    end
    
    specify "requires only one vehicle" do
      report = DailySummaryReport.new(@user, {
        :devices => [],
        :range => {
          :type => Report::DateRange::CUSTOM,
          :start => '02/01/2009',
          :end => '02/10/2009'
        }
      })
      report.validate
      report.should.not.be.valid

      report.errors.should.include 'You must choose one vehicle to run this report'
    end
  end

  context "Fuel Economy Report" do
    specify "works" do
      report = FuelEconomyReport.new(@user, {
        :devices => @devices,
        :range => {
          :type => Report::DateRange::CUSTOM,
          :start => '02/01/2009',
          :end => '02/10/2009'
        }
      })
      report.validate
      report.should.be.valid

      report.run
      
      report.data[0][:date].should.equal Date.parse('02/01/2009')
      report.data[1][:date].should.equal Date.parse('02/02/2009')
      report.data[2][:date].should.equal Date.parse('02/03/2009')
    end

    specify "requires only one vehicle" do
      report = FuelEconomyReport.new(@user, {
        :devices => [],
        :range => {
          :type => Report::DateRange::CUSTOM,
          :start => '02/01/2009',
          :end => '02/10/2009'
        }
      })
      report.validate
      
      report.should.not.be.valid
      report.errors.should.include 'You must choose one vehicle to run this report'
    end
  end

  context "Trip Detail Report" do
    specify "works" do
      report = TripDetailReport.new(@user, {
        :devices => @devices,
        :range => {
          :type => Report::DateRange::CUSTOM,
          :start => '02/01/2009',
          :end => '02/10/2009'
        }
      })
      report.validate
      report.should.be.valid

      report.run
      
      report.data.should.not.be.empty
    end

    specify "requires at least one vehicle" do
      report = TripDetailReport.new(@user, {
        :devices => [],
        :range => {
          :type => Report::DateRange::CUSTOM,
          :start => '02/01/2009',
          :end => '02/10/2009'
        }
      })
      report.validate
      
      report.should.not.be.valid
      report.errors.should.include 'You must choose one or more vehicles to run this report'
    end
  end
  
end
