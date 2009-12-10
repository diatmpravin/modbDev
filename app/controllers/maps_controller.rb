class MapsController < ApplicationController
  before_filter :set_device
  
  layout except_ajax('orig_maps')
  
  def index
    @devices = current_account.devices
    @geofences = current_account.geofences
    @landmarks = current_account.landmarks
    
    # Default the device shown if they only have one
    if @devices.length == 1
      @device = @devices.first
    end
  end
  
  def status
    if @device
      @devices = [@device]
    else
      @devices = current_account.devices
    end
    
    render :partial => 'status', :locals => {:devices => @devices}
  end
  
  protected
  def set_device
    @device = current_account.devices.find(params[:device_id]) unless params[:device_id].blank?
  end
end
