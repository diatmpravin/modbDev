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
    
    params[:report][:devices] = current_account.devices.find(
      params[:apply_ids].split(',')
    )
    
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
      
      with.json {
        if @report.valid?
          @report.run
          
          report_id = "#{current_user.id}_#{ActiveSupport::SecureRandom.hex(16)}"
          File.open(File.join(Rails.root, 'tmp', 'cache', "#{report_id}.html"), 'w') do |f|
            f.write(render_to_string(:action => 'report'))
          end
          File.open(File.join(Rails.root, 'tmp', 'cache', "#{report_id}.csv"), 'w') do |f|
            f.write(render_to_string(:text => @report.to_csv, :layout => false))
          end
          
          render :json => {:status => 'success', :report_id => report_id}
        else
          render :json => {
            :status => 'failure',
            :html => render_to_string(:partial => 'form', :locals => {:report => @report})
          }
        end
      }
    end
  end
  
  def show
    report_id = params[:id]
    
    respond_to do |format|
      format.html {
        render :file => File.join(Rails.root, 'tmp', 'cache', "#{report_id}.html"), :layout => 'report_blank'
      }
      format.csv {
        render :file => File.join(Rails.root, 'tmp', 'cache', "#{report_id}.csv"), :layout => false
      }
    end
  end
  
end
