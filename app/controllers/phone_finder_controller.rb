class PhoneFinderController < ApplicationController
  skip_before_filter :login_required
  
  layout 'phone_finder'
  
  # GET /phone_finder/popup
  def popup
    render :layout => 'external'
  end
  
  # GET /phone_finder
  def show
    redirect_to phone_finder_carriers_path
  end
  
end
