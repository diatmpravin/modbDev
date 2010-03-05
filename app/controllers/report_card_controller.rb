class ReportCardController < ApplicationController

  layout except_ajax('devices')

  # GET /report_card
  # Main view of the report card
  def show
    template = "list"
    @range_type = (params[:range_type] || 1).to_i

    @report_card = 
      if params[:group_id]
        group = current_account.groups.find(params[:group_id])
        
        if group.children.any?
          group_reports(group.children)
        elsif group.devices.any?
          template = "list_vehicles"
          GroupVehiclesReport.new(current_user, 
                                   :group => group, :range => {:type => @range_type}).tap {|g| g.run }
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
      GroupSummaryReport.new(current_user, :group => g, :range => {:type => @range_type}).tap {|g| g.run }
    end
  end

end
