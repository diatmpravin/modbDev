class GeofencesController < ApplicationController
  before_filter :new_geofence, :only => [:new, :create]
  before_filter :set_geofence, :only => [:edit, :update]
  
  layout :set_layout

  def index
    @geofences = search_on Geofence do
      current_account.geofences.paginate(:page => params[:page], :per_page => 30)
    end

    respond_to do |format|
      format.html
      format.json {
        render :json => @geofences
      }
    end
  end

  def new
  end

  def create
    save_record
  end

  def show
  end

  def edit
  end

  def update
    save_record
  end

  # DELETE /geofences/:id
  # Remove a geofence from the system
  def destroy
    current_account.geofences.destroy(params[:id])
    redirect_to geofences_path
  end

  protected

  def new_geofence
    @geofence = current_account.geofences.new
  end
  
  def set_geofence
    @geofence = current_account.geofences.find(params[:id])
  end
  
  def set_layout
    return nil if request.xhr?
    #return "geofences_map" if [:edit, :new, :update, :create].include?(action_name.to_sym)
    "geofences"
  end
  
  def save_record
    # If group ids are missing, blank them out
    params[:geofence]['device_group_ids'] ||= []
    
    if @geofence.update_attributes(params[:geofence])
      redirect_to geofences_path
    else
      render :action => @geofence.new_record? ? 'new' : 'edit'
    end
  end
end
