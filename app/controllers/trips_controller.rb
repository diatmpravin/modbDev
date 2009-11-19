class TripsController < ApplicationController
  before_filter :set_device, :only => [:index, :summary]
  before_filter :set_trip, :only => [:show, :edit, :update, :collapse, :expand]
  
  def index
    start_date = Date.parse(params[:start_date])
    end_date = Date.parse(params[:end_date])
    
    @date = start_date
    
    if @device
      @trips = @device.trips.in_range(start_date, end_date, current_user.zone).
        all(:include => :device)
    else
      @trips = Trip.in_range(start_date, end_date, current_user.zone).
        all(:conditions => {:device_id => current_account.device_ids}, :include => [:device, :tags])
    end
    
    respond_to do |format|
      format.html
      format.json {
        render :json => {:trips => @trips.map {|trip|
          {
            :id => trip.id,
            :device_id => trip.device_id,
            :start => trip.start.to_i + trip.start.in_time_zone(current_user.zone).utc_offset,
            :finish => trip.finish.to_i + trip.finish.in_time_zone(current_user.zone).utc_offset,
            :color => trip.device.color
          }
        }}
      }
    end
  end
  
  def show
    respond_to do |format|
      format.html
      format.json { render :json => @trip.to_json }
    end
  end
  
  def edit
  end
    
  def update
    params[:trip][:tag_ids] ||= []
    
    if @trip.update_attributes(params[:trip])
      render :json => {:status => 'success'}
    else
      render :json => {
        :status => 'failure',
        :html => render_to_string(:action => 'edit')
      }
    end
  end
  
  def collapse
    if @trip = @trip.collapse
      render :json => {
        :status => 'success',
        :view => render_to_string(:action => 'show'),
        :edit => render_to_string(:action => 'edit')
      }
    else
      render :json => {
        :status => 'failure'
      }
    end
  end
  
  def expand
    if new_trip = @trip.expand
      # Return the updated partials for the existing trip, along with the
      # partials for the newly expanded trip.
      render :json => {
        :status => 'success',
        :view => render_to_string(:action => 'show'),
        :edit => render_to_string(:action => 'edit'),
        :new_trip => begin
          @trip = new_trip
          {
            :id => @trip.id,
            :view => render_to_string(:action => 'show'),
            :edit => render_to_string(:action => 'edit')
          }
        end
      }
    else
      render :json => {
        :status => 'failure'
      }
    end
  end
  
  protected
  def set_trip
    @trip = Trip.find(params[:id])
    raise ActiveRecord::RecordNotFound unless current_account.device_ids.include?(@trip.device_id)
  end
  
  def set_device
    @device = current_account.devices.find(params[:device_id]) if params[:device_id]
  end
end
