class ReportCardController < ApplicationController

  layout except_ajax('devices')

  # GET /report_card
  # Main view of the report card
  def show
    template = "list"

    @report_card = 
      if params[:group_id]
        group = current_account.groups.find(params[:group_id])
        
        if group.children.any?
          group_reports(group.children)
        elsif group.devices.any?
          template = "list_vehicles"
          GroupVehiclesReport.new(current_user, 
                                   :group => group, :range => {:type => 1}).tap {|g| g.run }
        else
          []
        end
      else
        group_reports(current_account.groups.of_devices.roots)
      end
      

    if request.xhr?
      render :partial => template, :locals => {:report_card => @report_card}
    end
  end

  private

  def group_reports(groups)
    groups.map do |g|
      GroupSummaryReport.new(current_user, :group => g, :range => {:type => 1}).tap {|g| g.run }
    end
  end

end
