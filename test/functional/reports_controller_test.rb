require 'test_helper'

describe "Reports Controller", ActionController::TestCase do
  use_controller ReportsController
  
  setup do
    login_as :quentin
    @account = accounts(:quentin)
  end

  context "Running a Vehicle Report" do
    setup do
      # Each create call stores two copies of the report (HTML + CSV)
      Redis.expects(:build).returns(stub('Redis') {|r|
        r.expects(:[]=).times(3)
      })
    end
    
    def report_params(report_type)
      {
        :device_ids => devices(:quentin_device).id.to_s,
        :report => {
          :type => "#{report_type}",
          :range => {
            :type => Report::DateRange::CUSTOM,
            :start => '02/01/2009',
            :end => '02/10/2009'
          }
        },
        :format => 'json'
      }
    end

    specify "Vehicle Summary Report" do
      post :create, report_params(Report::VEHICLE_SUMMARY_REPORT)
      
      json['status'].should.equal 'success'
      json['report_id'].should =~ /[0-9a-f]{32}/
      assigns(:report).should.be.an.instance_of VehicleSummaryReport
    end

    specify "Daily Summary Report" do
      post :create, report_params(Report::DAILY_SUMMARY_REPORT)

      json['status'].should.equal 'success'
      json['report_id'].should =~ /[0-9a-f]{32}/
      assigns(:report).should.be.an.instance_of DailySummaryReport
    end

    specify "Fuel Economy Report" do
      post :create, report_params(Report::FUEL_ECONOMY_REPORT)
      
      json['status'].should.equal 'success'
      json['report_id'].should =~ /[0-9a-f]{32}/
      assigns(:report).should.be.an.instance_of FuelEconomyReport
    end

    specify "Trip Detail Report" do
      post :create, report_params(Report::TRIP_DETAIL_REPORT)

      json['status'].should.equal 'success'
      json['report_id'].should =~ /[0-9a-f]{32}/
      assigns(:report).should.be.an.instance_of TripDetailReport
    end

    specify "Fuel Summary Report" do
      post :create, report_params(Report::FUEL_SUMMARY_REPORT)

      json['status'].should.equal 'success'
      json['report_id'].should =~ /[0-9a-f]{32}/
      assigns(:report).should.be.an.instance_of FuelSummaryReport
    end
  end
  
  context "Running a Group Report" do
    setup do
      # Each create call stores two copies of the report (HTML + CSV)
      Redis.expects(:build).returns(stub('Redis') {|r|
        r.expects(:[]=).times(3)
      })
      
      devices(:quentin_device).groups << groups(:north)
    end
    
    def report_params(report_type)
      {
        :group_ids => groups(:north).id.to_s,
        :report => {
          :type => "#{report_type}",
          :range => {
            :type => Report::DateRange::CUSTOM,
            :start => '02/01/2009',
            :end => '02/10/2009'
          }
        },
        :format => 'json'
      }
    end

    specify "Vehicle Summary Report" do
      post :create, report_params(Report::VEHICLE_SUMMARY_REPORT)
      
      json['status'].should.equal 'success'
      json['report_id'].should =~ /[0-9a-f]{32}/
      assigns(:report).should.be.an.instance_of VehicleSummaryReport
    end

    specify "Trip Detail Report" do
      post :create, report_params(Report::TRIP_DETAIL_REPORT)

      json['status'].should.equal 'success'
      json['report_id'].should =~ /[0-9a-f]{32}/
      assigns(:report).should.be.an.instance_of TripDetailReport
    end

    specify "Fuel Summary Report" do
      post :create, report_params(Report::FUEL_SUMMARY_REPORT)

      json['status'].should.equal 'success'
      json['report_id'].should =~ /[0-9a-f]{32}/
      assigns(:report).should.be.an.instance_of FuelSummaryReport
    end
  end
  
  context "Retrieving a report for display" do
    specify "Retrieving a stored HTML report" do
      Redis.expects(:build).returns(stub('Redis') {|r|
        r.expects(:[]).with('7a7a7a7a7a7a7a7a9b9b9b9b9b9b9b9b.html').returns('bananas')
      })
      get :show, {:id => '7a7a7a7a7a7a7a7a9b9b9b9b9b9b9b9b'}
      
      template.should.be 'show'
      response.body.should =~ /bananas/
    end
    
    specify "Retrieving a stored CSV report" do
      Redis.expects(:build).returns(stub('Redis') {|r|
        r.expects(:[]).with('7a7a7a7a7a7a7a7a9b9b9b9b9b9b9b9b.title').returns('The Banana Show')
        r.expects(:[]).with('7a7a7a7a7a7a7a7a9b9b9b9b9b9b9b9b.csv').returns('bananas')
      })
      get :show, {:id => '7a7a7a7a7a7a7a7a9b9b9b9b9b9b9b9b', :format => 'csv'}
      
      response.body.should == 'bananas'
    end
  end
end
