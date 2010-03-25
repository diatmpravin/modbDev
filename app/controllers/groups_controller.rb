class GroupsController < ApplicationController

  before_filter :set_group, :only => [:show, :edit, :update, :live_look]

  layout except_ajax('groups')

  # GET /groups
  # Show the list of device groups
  def index
    @groups = search_on DeviceGroup do
      current_account.device_groups.paginate :page => params[:page], :per_page => 30
    end
  end

  # GET /groups/:id
  # Show all vehicles in this group
  def show
    @devices = @group.devices.paginate :page => params[:page], :per_page => 30
  end

  # GET /groups/new
  # New group form
  def new
    @group = current_account.device_groups.new
  end

  # POST /groups
  # Create a new group
  def create
    @group = current_account.device_groups.build(params[:group])
    @group.parent = current_account.device_groups.find_by_id(params[:group][:parent_id])
    @group.save
    
    redirect_to device_groups_path
  end

  # GET /groups/:id/edit
  # Show the edit form for this group
  def edit
  end

  # PUT /groups/:id
  # Update the given group
  def update
    # TODO: Add error handling
    # I believe "name already taken" and "group move invalid" are the two possible errors
    #
    @group.update_attributes(params[:group])
    if params[:group][:parent_id]
      if params[:group][:parent_id].blank?
        @group.move_to_root
      else
        @group.move_to_child_of(params[:group][:parent_id].to_i)
      end
    end
    
    respond_to do |format|
      format.html {
        redirect_to device_groups_path
      }
      format.json {
        render :json => {:status => 'success'}
      }
    end
  end
  
  # DELETE /groups/:id
  # Destroy the given group
  def destroy
    current_account.device_groups.destroy(params[:id])
    redirect_to device_groups_path
  end

  # GET /groups/:id/live_look
  # Show all vehicles in this group on live look
  def live_look
    ids = @group.device_ids
    if ids.empty?
      flash[:warning] = "Group must have at least one vehicle to view it in live look"
      redirect_to device_groups_path
    else
      redirect_to live_look_devices_path(:device_ids => ids.join(","))
    end
  end

  protected

  def set_group
    @group = current_account.device_groups.find(params[:id])
  end

end
