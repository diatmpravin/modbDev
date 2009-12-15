require 'test_helper'

describe "Reports Controller", ActionController::TestCase do
  use_controller ReportsController
  
  setup do
    login_as :quentin
    @account = accounts(:quentin)
  end

  context "Running a report" do
    def report_params(report_type)
      {
        :apply_ids => [
          devices(:quentin_device).id
        ],
        :report => {
          :type => "#{report_type}",
          :range => {
            :type => 7,
            :start => '02/01/2009',
            :end => '02/10/2009'
          }
        }
      }
    end

    specify "Vehicle Summary Report" do
      post :create, report_params(0)
      
      json['status'].should.equal 'success'
      assigns(:report).should.be.an.instance_of VehicleSummaryReport
    end

    specify "Daily Summary Report" do
      post :create, report_params(1)

      json['status'].should.equal 'success'
      assigns(:report).should.be.an.instance_of DailySummaryReport
    end

    specify "Fuel Economy Report" do
      post :create, report_params(2)
      
      json['status'].should.equal 'success'
      assigns(:report).should.be.an.instance_of FuelEconomyReport
    end

    specify "Trip Detail Report" do
      post :create, report_params(3)

      json['status'].should.equal 'success'
      assigns(:report).should.be.an.instance_of TripDetailReport
    end

    specify "Fuel Summary Report" do
      post :create, report_params(4)

      json['status'].should.equal 'success'
      assigns(:report).should.be.an.instance_of FuelSummaryReport
    end
  end
  
end
