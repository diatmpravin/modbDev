class ReportCardController < ApplicationController

  layout except_ajax('devices')

  # GET /report_card
  # Main view of the report card
  def show
    groups = 
      if params[:group_id]
        current_account.groups.find(params[:group_id]).children
      else
        current_account.groups.of_devices.roots
      end
      
    @report_card = groups.map do |g|
      GroupSummaryReport.new(current_user, :group => g, :range => {:type => 1}).tap {|g| g.run }
    end

    if request.xhr?
      render :partial => "list", :locals => {:report_card => @report_card}
    end
  end

end
