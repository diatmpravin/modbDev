class Import::VehiclesController < ApplicationController
  before_filter :require_role

  layout except_ajax('devices')

  # GET /import/vehicles
  def index
  end

  # POST /import/vehicles
  # Takes an uploaded file named :upload, checks to
  # see validitity of data
  def create
    @parser = Import::Parser.new
    @parser.parse(params[:upload])

    if @parser.valid?
      @processor = Import::VehicleImporter.new(current_account, current_user)
      @processor.store(params[:upload].original_filename, @parser.data)
    else
      flash.now[:error] = @parser.errors[0]
      render :action => "index"
    end
  end

  protected

  def require_role
    redirect_to root_path unless current_user.has_role?(User::Role::FLEET)
  end

end
