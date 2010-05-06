class GroupsController < ApplicationController
  require_role User::Role::FLEET, :except => [:index, :show]
  before_filter :new_group, :only => [:new, :create]
  before_filter :set_group, :only => [:show, :edit, :update, :live_look]

  layout nil
  
  def index
    respond_to do |format|
      format.html {
        redirect_to report_card_path
      }
      format.json {
        render :json => {
          :html => render_to_string(:partial => 'list')
        }
      }
    end
  end
  
  def new
  end
  
  def create
    update_record
  end

  def edit
  end

  def update
    if params[:device_group][:parent_id] == '0'
      # Root
      params[:device_group][:parent_id] = nil
    end
    
    update_record
  rescue ActiveRecord::ActiveRecordError
    render :json => {
      :status => 'failure',
      :error => 'Cannot move group inside its own subgroups.'
    }
  end
  
  def destroy
    current_account.device_groups.find(params[:id]).destroy_and_rollup
    
    render :json => {
      :status => 'success'
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
  
  def update_record
    if @group.update_attributes(params[:device_group])
      render :json => {
        :status => 'success'
      }
    else
      render :json => {
        :status => 'failure',
        :html => render_to_string(:partial => 'form', :locals => {:group => @group}),
        :error => @group.errors.map {|e| "#{e.first.capitalize} #{e.last}"}
      }
    end
  end
  
  def index_json_options
    {:only => [:id, :name]}
  end
end
