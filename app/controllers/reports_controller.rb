class ReportsController < ApplicationController
  layout except_ajax('reports')
  
  def create
    params[:report] ||= {}
    
    # Get our list of devices
    params[:report][:devices] = current_account.devices.find(
      params[:apply_ids].split(',')
    )
    
    # Get our report object
    report_type = params[:report][:type].to_i
    @report = Report.valid_reports[report_type].new(current_user, params[:report])
    @report.validate
    
    # Return a JSON response
    if @report.valid?
      @report.run
      
      @report_id = ActiveSupport::SecureRandom.hex(16)
      
      redis = Redis.new
      redis["#{@report_id}.html"] = render_to_string(:action => 'report')
      redis["#{@report_id}.csv"] = render_to_string(:text => @report.to_csv, :layout => false)
      
      render :json => {:status => 'success', :report_id => @report_id}
    else
      render :json => {:status => 'failure', :errors => @report.errors}
    end
  end
  
  def show
    @report_id = params[:id]
    
    redis = Redis.new
    
    respond_to do |format|
      format.html {
        @content = redis["#{@report_id}.html"]
        render :action => 'show', :layout => 'report_blank'
      }
      format.csv {
        render :text => redis["#{@report_id}.csv"], :layout => false
      }
    end
  end
  
end
