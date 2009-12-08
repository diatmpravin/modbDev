class DeviceProfilesController < ApplicationController
  before_filter :new_profile, :only => [:new, :create]
  before_filter :set_profile, :only => [:edit, :update, :destroy]
  
  layout except_ajax('device_profiles')
  
  def index
    @device_profiles = current_account.device_profiles
  end
  
  def new
  end
  
  def create
    if @device_profile.update_attributes(params[:device_profile])
      redirect_to :action => 'index'
    else
      render :action => 'new'
    end
  end
  
  def edit
  end
  
  def update
    if @device_profile.update_attributes(params[:device_profile])
      redirect_to :action => 'index'
    else
      render :action => 'edit'
    end
  end
  
  def destroy
    @device_profile.destroy
    
    redirect_to :action => 'index'
  end
  
  protected
  def new_profile
    @device_profile = current_account.device_profiles.new
  end
  
  def set_profile
    @device_profile = current_account.device_profiles.find(params[:id])
  end
end
