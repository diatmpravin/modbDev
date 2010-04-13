class DashboardController < ApplicationController
  layout except_ajax('internal')

  def show
    @root = current_user.device_group_or_root
    
    @range_type = (params[:range_type] || 1).to_i
    
    respond_to do |format|
      format.html
      format.json {
        render :json => {
          :status => 'success',
          :id => dom_id(@root),
          :html => render_to_string(:partial => 'dashboard/tree', :locals => {:node => @root})
        }
      }
    end
  end
end
