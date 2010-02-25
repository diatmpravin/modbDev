class GroupsController < ApplicationController

  before_filter :set_group, :only => [:show, :edit, :update, :live_look]

  layout except_ajax('groups')

  # GET /groups
  # Show the list of device groups
  def index
    @groups = search_on Group do
      current_account.groups.of_devices.paginate :page => params[:page], :per_page => 30
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
    @group = Group.new
  end

  # POST /groups
  # Create a new group
  def create
    @group = current_account.groups.of_devices.create params[:group]
    redirect_to groups_path
  end

  # GET /groups/:id/edit
  # Show the edit form for this group
  def edit
  end

  # PUT /groups/:id
  # Update the given group
  def update
    @group.update_attributes(params[:group])
    redirect_to groups_path
  end

  # DELETE /groups/:id
  # Destroy the given group
  def destroy
    current_account.groups.of_devices.destroy(params[:id])
    redirect_to groups_path
  end

  # GET /groups/:id/live_look
  # Show all vehicles in this group on live look
  def live_look
    ids = @group.device_ids
    if ids.empty?
      flash[:warning] = "Group must have at least one vehicle to view it in live look"
      redirect_to groups_path
    else
      redirect_to live_look_devices_path(:device_ids => ids.join(","))
    end
  end

  protected

  def set_group
    @group = current_account.groups.of_devices.find(params[:id])
  end

end
