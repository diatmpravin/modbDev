class GeofencesController < ApplicationController
  require_role User::Role::GEOFENCE
  before_filter :new_geofence, :only => [:new, :create]
  before_filter :set_geofence, :only => [:edit, :update, :destroy]
  
  layout except_ajax('geofences')
  
  def index
    @geofences = current_account.geofences
    
    respond_to do |format|
      format.html {
        redirect_to dashboard_path(:anchor => 'geofences')
      }
      
      format.json {
        render :json => @geofences.to_json(index_json_options)
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

  def destroy
    @geofence.destroy
    
    render :json => {:status => 'success'}
  end

  protected

  def new_geofence
    @geofence = current_account.geofences.new
  end
  
  def set_geofence
    @geofence = current_account.geofences.find(params[:id])
  end
  
  def save_record
    # If group ids are missing, blank them out
    params[:geofence]['device_group_ids'] ||= []
    
    if @geofence.update_attributes(params[:geofence])
      render :json => {
        :status => 'success',
        :geofence => @geofence
      }
    else
      render :json => {
        :status => 'failure',
        :html => render_to_string(:action => @geofence.new_record? ? 'new' : 'edit')
      }
    end
  end
  
  def index_json_options
    {:only => [:id, :name, :geofence_type, :coordinates]}
  end
end
