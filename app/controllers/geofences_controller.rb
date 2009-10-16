class GeofencesController < ApplicationController
  before_filter :set_device
  before_filter :set_devices
  before_filter :set_geofence, :only => [:show, :edit, :update, :destroy]
  
  layout except_ajax('geofences')
  
  def index
    if @device
      @geofences = @device.geofences
    else
      @geofences = current_account.geofences
    end
    
    respond_to do |format|
      format.html
      format.json {
        render :text => @geofences.to_json(:methods => [:device_ids])
      }
    end
  end
  
  def new
    @geofence = current_account.geofences.new
  end
  
  def create
    @geofence = current_account.geofences.new
    
    if @geofence.update_attributes(params[:geofence])
      respond_to do |format|
        format.json {
          render :json => {:status => 'success'}
        }
      end
    else
      respond_to do |format|
        format.json {
          render :json => {:status => 'failure'}
        }
      end
    end
  end
  
  def show
  end
  
  def edit
  end
  
  def update
    params[:geofence][:device_ids] ||= []
    params[:geofence][:alert_recipient_ids] ||= []
    
    if @geofence.update_attributes(params[:geofence])
      render :json => {:status => 'success'}
    else
      render :json => {
        :status => 'failure',
        :html => render_to_string(:action => 'edit')
      }
    end
  end
  
  def destroy
    @geofence.destroy
    
    render :json => {:status => 'success'}
  end
  
  protected
  def set_device
    @device = current_account.devices.find(params[:device_id]) if params[:device_id]
  end
  
  def set_devices
    @devices = current_account.devices
  end
  
  def set_geofence
    @geofence = current_account.geofences.find(params[:id])
  end
end
