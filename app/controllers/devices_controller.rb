class DevicesController < ApplicationController
  before_filter :set_device, :only => [:edit, :update, :destroy, :show, :position]
  before_filter :set_devices, :except => [:show, :destroy]
  
  layout except_ajax('devices')

  def index
    respond_to do |format|
      format.html {
        @device = Device.new
      }
      format.json {
        render :json => @devices.to_json(
          :methods => [:color, :connected],
          :include => {
            :position => {
              :methods => :time_of_day
            }            
          }
        )
      }
    end
  end
  
  def show
    respond_to do |format|
      format.html
      format.json {
        render :json => [@device].to_json(
          :methods => [:color, :connected],
          :include => {
            :position => {
              :methods => :time_of_day
            }
          }
        )
      }
    end
  end
  
  def create
    if params[:imei] == params[:imei_confirmation] && 
      (params[:imei].any? || params[:imei_confirmation].any?)
      @device = current_account.devices.build(:name => params[:name])
      @device.user = current_user
      @device.tracker = Tracker.find_by_imei_number(params[:imei])

      if @device.tracker.nil?
        error = "Unknown Tracker"
      else
        if !@device.save
          error = @device.errors.full_messages
        end
      end
    else
      error = "Numbers do not match"
    end
    
    if error
      render :json => {
        :status => 'failure',
        :error => error
      }
    else
      flash[:notice] = 'Vehicle added'
      render :json => {:status => 'success'}
    end
  end
  
  def edit
  end
  
  def update
    params[:device][@device.id.to_s][:alert_recipient_ids] ||= []
    @device.tracker = Tracker.find_by_imei_number(params[:device][@device.id.to_s][:imei_number])
    
    if @device.update_attributes(params[:device][@device.id.to_s])
      render :json => {:status => 'success'}
    else
      render :json => {
        :status => 'failure',
        :html => render_to_string(:action => 'edit')
      }
    end
  end
  
  def destroy
    @device.destroy
    
    render :json => {:status => 'success'}
  end
  
  def position
    respond_to do |format|
      format.html
      format.json {
        render :json => @device.points.last
      }
    end
  end
  
  protected
  def set_device
    @device = current_account.devices.find(params[:id])
  end
  
  def set_devices
    @devices = current_account.devices
  end
end
