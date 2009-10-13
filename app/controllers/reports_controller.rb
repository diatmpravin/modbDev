class ReportsController < ApplicationController
  layout except_ajax('reports')
  
  def index
    @report = Report.new(current_account, params[:report] || {})
    @devices = current_account.devices.all(:select => 'name, id').map {|d| [d.name, d.id]}
    
    @report.run
    
    if @report.error
      flash.now[:error] = @report.error
    end
  end
  
  def create
    @report = Report.new(current_account, params[:report] || {})
    @report.run
    
    if @report.error
      flash.now[:error] = @report.error
      render :action => 'index'
      return
    end
    
    render :action => 'report', :layout => 'report_blank'
  end
  
end
