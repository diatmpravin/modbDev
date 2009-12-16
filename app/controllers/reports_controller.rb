class ReportsController < ApplicationController
  layout except_ajax('reports')
  
  def create
    params[:report] ||= {}
    
    # Get our list of devices
    if params[:device_ids]
      params[:report][:devices] = current_account.devices.find(
        params[:device_ids].split(',')
      )
    elsif params[:group_ids]
      params[:report][:devices] = current_account.devices.all(
        :joins => :groups,
        :conditions => {:groups => {:id => params[:group_ids].split(',')}}
      )
    end
    
    # Get our report object
    report_type = params[:report][:type].to_i
    @report = Report::REPORTS[report_type].new(current_user, params[:report])
    @report.validate
    
    # Return a JSON response
    if @report.valid?
      @report.run
      
      @report_id = ActiveSupport::SecureRandom.hex(16)
      
      redis = Redis.build
      redis["#{@report_id}.html"] = render_to_string(:action => 'report', :layout => 'report_blank')
      redis["#{@report_id}.csv"] = render_to_string(:text => @report.to_csv, :layout => false)
      
      # TODO: If necessary, a background worker will create the report
      render :json => {:status => 'success', :report_id => @report_id}
    else
      render :json => {:status => 'failure', :errors => @report.errors}
    end
  end
  
  def show
    @report_id = params[:id]
    
    redis = Redis.build
    
    respond_to do |format|
      format.html {
        @content = redis["#{@report_id}.html"]
        render :action => 'show', :layout => false
      }
      format.csv {
        render :text => redis["#{@report_id}.csv"], :layout => false
      }
    end
  end
  
end
