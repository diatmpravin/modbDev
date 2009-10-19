class ReportsController < ApplicationController
  layout except_ajax('reports')
  
  def index
    @devices = current_account.devices.all
  end
  
  def create
    @report = Report.new(current_account, params[:report] || {})
    @report.run
    
    if @report.error
      flash.now[:error] = @report.error

      render :action => 'index'
    else
      render :action => 'report', :layout => 'report_blank'
    end
  end
  
end
