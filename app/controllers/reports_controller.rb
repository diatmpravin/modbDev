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
      
      report_id = ActiveSupport::SecureRandom.hex(16)
      @filename = "#{current_user.id}_#{report_id}"
      
      # TODO: Cache HTML and CSV reports in Redis
      File.open(File.join(Rails.root, 'tmp', 'cache', "#{@filename}.html"), 'w') do |f|
        f.write(render_to_string(:action => 'report'))
      end
      File.open(File.join(Rails.root, 'tmp', 'cache', "#{@filename}.csv"), 'w') do |f|
        f.write(render_to_string(:text => @report.to_csv, :layout => false))
      end
      
      render :json => {:status => 'success', :report_id => @filename}
    else
      render :json => {:status => 'failure', :errors => @report.errors}
    end
  end
  
  def show
    @filename = params[:id]
    
    # TODO: Pull HTML or CSV report out of Redis
    respond_to do |format|
      format.html {
        render :file => File.join(Rails.root, 'tmp', 'cache', "#{@filename}.html"), :layout => 'report_blank'
      }
      format.csv {
        render :file => File.join(Rails.root, 'tmp', 'cache', "#{@filename}.csv"), :layout => false
      }
    end
  end
  
end
