class DeviceProfilesController < ApplicationController
  #before_filter :set_device, :only => [:edit, :update, :destroy, :show, :position]
  before_filter :set_profiles, :only => [:index]
  
  layout except_ajax('device_profiles')
  
  def index
  end
  
  protected
  def set_profiles
    @profiles = current_account.device_profiles
  end
end
