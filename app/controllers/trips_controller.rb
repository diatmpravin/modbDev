class TripsController < ApplicationController
  before_filter :set_device, :only => [:index, :summary]
  before_filter :set_trip, :only => [:show, :edit, :update, :collapse, :expand]
  
  def index
    start_date = Date.parse(params[:start_date])
    end_date = Date.parse(params[:end_date])
    
    @date = start_date
    
    if @device
      @trips = @device.trips.in_range(start_date, end_date, current_user.zone).
        all(:include => [:device, :tags])
    else
      @trips = Trip.in_range(start_date, end_date, current_user.zone).
        all(:conditions => {:device_id => current_account.device_ids}, :include => [:device, :tags])
    end
  end
  
  # Return trip summary information for the given date range, without
  # deep-loading any trips. Used by the history scroller.
  def summary
    start_date = Date.parse(params[:start_date])
    end_date = Date.parse(params[:end_date])
    
    start_range = Trip.in_range(start_date, end_date, current_user.zone).multi_count(
      :group => ["DATE_FORMAT(TIMESTAMPADD(SECOND,#{start_date.beginning_of_day.in_time_zone(current_user.zone).utc_offset},start),'%m/%d/%Y')", 'device_id'],
      :conditions => {:device_id => current_account.device_ids}
    )
    finish_range = Trip.in_range(start_date, end_date, current_user.zone).multi_count(
      :group => ["DATE_FORMAT(TIMESTAMPADD(SECOND,#{start_date.beginning_of_day.in_time_zone(current_user.zone).utc_offset},finish),'%m/%d/%Y')", 'device_id'],
      :conditions => {:device_id => current_account.device_ids}
    )
    
    trip_counts = Hash.new {|hash, key| hash[key] = Hash.new(0)}
    start_range.each do |r|
      trip_counts[r[0][0]][r[0][1].to_i] = r[1]
    end
    finish_range.each do |r|
      trip_counts[r[0][0]][r[0][1].to_i] = [trip_counts[r[0][0]][r[0][1].to_i], r[1]].max
    end
    
    respond_to do |format|
      format.json {
        render :json => trip_counts
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
