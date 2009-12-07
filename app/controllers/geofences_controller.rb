class GeofencesController < ApplicationController
  before_filter :new_geofence, :only => [:new, :create]
  before_filter :set_geofence, :only => [:show, :edit, :update, :destroy]
  before_filter :set_device
  before_filter :set_devices
  
  layout except_ajax('geofences')
  
  def index
    @geofences = current_account.geofences
    
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
    save_geofence(params[:geofence])
  end
  
  def show
  end
  
  def edit
  end
  
  def update
    save_geofence(params[:geofence])
  end
  
  def destroy
    @geofence.destroy
    
    respond_to do |format|
      format.json {
        render :json => {
          :status => 'success'
        }
      }
    end
  end
  
  protected
  def new_geofence
    @geofence = current_account.geofences.new
  end
  
  def set_geofence
    @geofence = current_account.geofences.find(params[:id])
  end
  
  def set_device
    @device = current_account.devices.find(params[:device_id]) if params[:device_id]
  end
  
  def set_devices
    @devices = current_account.devices
  end
  
  def save_geofence(record)
    # If device ids or alert_recipient ids are missing, blank them out
    record = {:device_ids => [], :alert_recipient_ids => []}.merge(record)
    
    if @geofence.update_attributes(record)
      respond_to do |format|
        format.json {
          render :json => {
            :status => 'success',
            :view => render_to_string(:action => 'show'),
            :edit => render_to_string(:action => 'edit')
          }
        }
      end
    else
      respond_to do |format|
        format.json {
          render :json => {
            :status => 'failure',
            :html => render_to_string(
              :action => @geofence.new_record? ? 'new' : 'edit'
            )
          }
        }
      end
    end
  end
end
