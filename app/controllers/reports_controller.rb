class ReportsController < ApplicationController
  layout except_ajax('reports')

  REPORTS = {
    0 => VehicleSummaryReport,
    1 => DailySummaryReport,
    2 => FuelEconomyReport,
    3 => TripDetailReport,
    4 => FuelSummaryReport
  }.freeze unless defined?(REPORTS)
  
  def index
    @devices = current_user.devices.all
    @report = Report.new(current_user)
    @reports = REPORTS
  end
  
  def create
    params[:report] ||= {}

    # Devices come in as devices[id] = (1|0) so we need to get the actual device
    # objects from the database.
    (params[:devices] || []).map do |id, selected|
      selected == '1' ? id : nil
    end.compact.tap do |d|
      params[:report][:devices] = current_user.devices.find(d)
    end

    # Get our report object
    report_id = params[:report][:type].to_i
    @report = REPORTS[report_id].new(current_user, params[:report])
    @report.validate

    respond_to do |with|
      with.html do
        if @report.valid?
          @report.run
          render :action => 'report', :layout => 'report_blank'
        else
          render :action => 'error', :layout => false
        end
      end

      with.csv do
        # The export to CSV button is only visible once
        # the report has been run once already, so we know the values
        # are valid
        @report.run
        render :text => @report.to_csv, :layout => false
      end
    end
  end
  
end
