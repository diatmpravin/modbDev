class Import::VehiclesController < ApplicationController
  before_filter :require_role

  layout except_ajax('devices')

  # GET /import/vehicles
  def index
  end

  # POST /import/vehicles
  # Takes an uploaded file named :upload and attempts
  # to parse it into usable vehicle information
  def create
  end

  protected

  def require_role
    redirect_to root_path unless current_user.has_role?(User::Role::FLEET)
  end

end
