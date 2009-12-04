class TrackersController < ApplicationController
  before_filter :set_tracker, :only => [:edit, :update, :destroy, :get_info, :configure]
  
  layout except_ajax('trackers')
  
  def index
    @trackers = Tracker.all(tracker_options)
  end
  
  def new
    @tracker = Tracker.new
  end
  
  def create
    @tracker = Tracker.new(params[:tracker])
    
    if @tracker.save
      redirect_to :action => 'index'
    else
      render :action => 'new'
    end
  end
  
  def edit
  end
  
  def update
    if @tracker.update_attributes(params[:tracker])
      redirect_to :action => 'index'
    else
      render :action => 'edit'
    end
  end
  
  def destroy
    @tracker.destroy
    
    redirect_to :action => 'index'
  end
  
  def get_info
    if @tracker.sim_number.blank?
      render :action => 'edit'
      return
    end
    
    @jasper = Jasper.new
    @jasper.get_sim_info(@tracker.sim_number)
    
    if @tracker.msisdn_number.blank? && !@jasper.error
      @tracker.update_attribute(:msisdn_number, @jasper.response[:msisdn])
    end
    
    render :action => 'edit'
  end
  
  def configure
    @response = JasperSmsGateway.send(@tracker.msisdn_number, params[:command], '\$\$')
    @response ||= 'No response received'
    
    render :action => 'edit'
  end
  
  protected
  def set_tracker
    @tracker = Tracker.find(params[:id])
  end
  
  def tracker_options
    {
      :select => 'trackers.*, devices.id AS device_id',
      :joins => 'LEFT JOIN devices ON devices.tracker_id = trackers.id',
      :order => params[:order] || 'imei_number'
    }
  end
end
