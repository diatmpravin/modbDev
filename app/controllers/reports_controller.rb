class ReportsController < ApplicationController
  layout except_ajax('reports')
  
  def index
    @devices = current_account.devices.all
    @report = Report.new(current_account)
  end
  
  def create
    params[:report] ||= {}

    # Devices come in as devices[id] = (1|0) so we need to get the actual device
    # objects from the database.
    (params[:devices] || []).map do |id, selected|
      selected == '1' ? id : nil
    end.compact.tap do |d|
      params[:report][:devices] = current_account.devices.find(d)
    end

    @report = Report.new(current_account, params[:report])
    @report.run

    render :action => (@report.valid? ? 'report' : 'error'), :layout => 'report_blank'
  end
  
end
