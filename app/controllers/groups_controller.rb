class GroupsController < ApplicationController

  layout except_ajax('groups')

  # GET /groups
  # Show the list of device groups
  def index
    @groups = current_account.groups.of_devices
  end

end
