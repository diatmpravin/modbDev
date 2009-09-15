class PhoneFinder::CarriersController < ApplicationController
  skip_before_filter :login_required
  skip_before_filter :require_account_is_setup
  
  rescue_from ActiveResource::ResourceNotFound do
    render phone_finder_carriers_path
  end
  
  before_filter :set_carrier, :except => [:index]
  layout :layout
  
  # GET /phone_finder/carriers
  def index
    @carriers = PhonesDatabase::Carrier.find(:all)
  end
  
  # GET /phone_finder/carriers/:id
  def show
    @manufacturers = PhonesDatabase::Manufacturer.find(:all)
  end
  
  protected
  
  def layout
    'phone_finder' unless request.xhr?
  end
    
  def set_carrier
    @carrier = PhonesDatabase::Carrier.find(params[:id])
  rescue
    @carrier = PhonesDatabase::Carrier.find(params[:carrier_id])
  end
end
