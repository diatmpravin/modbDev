class TrackersController < ApplicationController
  before_filter :require_role
  before_filter :new_tracker, :only => [:new, :create]
  before_filter :set_tracker,  :only => [:edit, :update, :destroy, :get_info, :configure]

  layout except_ajax('trackers')
  
  def index
    @trackers = Tracker.all(tracker_options)
  end
  
  def new
  end
  
  def create
    @tracker.account = current_account.self_and_descendants.find(params[:tracker][:account_id])

    if @tracker.update_attributes(params[:tracker])
		redirect_to :action => 'index'
    else
      render :action => 'new'
    end
  end
  
  def edit
  end
  
  def update
    @tracker.account = current_account.self_and_descendants.find(params[:tracker][:account_id])

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
  def require_role
    redirect_to root_path unless current_user.has_role?(User::Role::RESELLER) &&
      current_account.reseller?
  end
  
  def set_tracker
    @tracker = Tracker.find(params[:id])
  end

  def new_tracker
    @tracker = current_account.trackers.new
  end
  
  def tracker_options
    {
      :select => 'trackers.*, devices.id AS device_id',
      :joins => 'LEFT JOIN devices ON devices.tracker_id = trackers.id',
      :order => params[:order] || 'imei_number'
    }
  end
end
