class GroupsController < ApplicationController
  before_filter :new_group, :only => [:new, :create]
  before_filter :set_group, :only => [:show, :edit, :update, :live_look]

  layout nil
  
  def index
    redirect_to report_card_path
  end
  
  def new
  end
  
  def create
    if @group.update_attributes(params[:device_group])
      root = current_user.device_group_or_root
      
      render :json => {
        :status => 'success',
        :html => render_to_string(:partial => 'report_card/tree', :locals => {:node => root}),
        :id => dom_id(root)
      }
    else
      render :json => {
        :status => 'failure',
        :html => render_to_string(:partial => 'form', :locals => {:group => @group})
      }
    end
  end

  def edit
  end

  def update
    if @group.update_attributes(params[:device_group])
      root = current_user.device_group_or_root
      
      render :json => {
        :status => 'success',
        :html => render_to_string(:partial => 'report_card/tree', :locals => {:node => root}),
        :id => dom_id(root)
      }
    else
      render :json => {
        :status => 'failure',
        :html => render_to_string(:partial => 'form', :locals => {:group => @group}),
        :error => @group.errors.map {|e| "#{e.first.capitalize} #{e.last}"}
      }
    end
  rescue ActiveRecord::ActiveRecordError
    render :json => {
      :status => 'failure',
      :error => 'Cannot move group inside its own subgroups.'
    }
  end
  
  def destroy
    current_account.device_groups.find(params[:id]).destroy_and_rollup
    
    root = current_user.device_group_or_root
    
    render :json => {
      :status => 'success',
      :html => render_to_string(:partial => 'report_card/tree', :locals => {:node => root}),
      :id => dom_id(root)
    }
  end

  # GET /groups/:id/live_look
  # Show all vehicles in this group on live look
  # def live_look
    # ids = @group.device_ids
    # if ids.empty?
      # flash[:warning] = "Group must have at least one vehicle to view it in live look"
      # redirect_to device_groups_path
    # else
      # redirect_to live_look_devices_path(:device_ids => ids.join(","))
    # end
  # end

  protected

  def new_group
    @group = current_account.device_groups.new
  end
  
  def set_group
    @group = current_account.device_groups.find(params[:id])
  end
end
