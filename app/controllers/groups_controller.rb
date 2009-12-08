class GroupsController < ApplicationController

  layout except_ajax('groups')

  # GET /groups
  # Show the list of device groups
  def index
    @groups = current_account.groups.of_devices
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
    @group = current_account.groups.of_devices.find(params[:id])
  end

  # PUT /groups/:id
  # Update the given group
  def update
    @group = current_account.groups.of_devices.find(params[:id])
    @group.update_attributes(params[:group])
    redirect_to groups_path
  end

end
