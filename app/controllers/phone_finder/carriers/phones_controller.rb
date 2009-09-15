class PhoneFinder::Carriers::PhonesController < ApplicationController
  skip_before_filter :login_required
  skip_before_filter :require_account_is_setup
  
  rescue_from ActiveResource::ResourceNotFound do
    render phone_finder_carriers_path
  end
  
  before_filter :set_carrier
  before_filter :set_manufacturer
  before_filter :set_phone_and_compatibilities, :only => [:show]
  layout :layout
  
  # GET /phone_finder/carriers/:id/phones
  def index
    if @manufacturer
      @phones = @manufacturer.phones
      @terms = {:manufacturer_id => @manufacturer.id}
    else
      result = PhonesDatabase::Finder.search(:query => params[:query], :carrier => @carrier.id, :app => Application::SCHLAGE)
      @phones = result.count.to_i > 0 ? result.phones : []
      @terms = {:query => params[:query]}
    end
  end
  
  # GET /phone_finder/carriers/:id/phones/:id
  def show
    @terms = {}
    @terms[:manufacturer_id] = @manufacturer.id if @manufacturer
    @terms[:query] = params[:query] if params[:query]
    
    # How awesome IS this phone?
    if @compatibilities.select {|c| c.works == "yes"}.any?
      @status = "green"
    elsif @compatibilities.select {|c| c.works == "no"}.any?
      @status = "red"
    else
      use_default_status
    end
  end
  
  protected

  class Application
    SCHLAGE = 9
  end
  
  class Carrier
    ALLTEL = 5
    NEXTEL = 6
    VERIZON = 3
    USCELLULAR = 7
  end
  
  class Technology
    WINDOWS_MOBILE = 2
    PALM_OS = 7
  end
  
  class Manufacturer
    BLACKBERRY = 1
  end

  # Because we don't have any testing data about this phone, make a guess as to whether
  # or not it supports the application.
  # 
  # FIXME: Don't hard-code all this stuff?
  def use_default_status
    if @phone.technologies.map {|k| k.id}.include?(Technology::WINDOWS_MOBILE)
      @status = "green"
    elsif @phone.technologies.map {|k| k.id}.include?(Technology::PALM_OS)
      @status = "red"
    elsif @phone.manufacturer_id == Manufacturer::BLACKBERRY
      @status = "green"
    elsif [Carrier::ALLTEL, Carrier::NEXTEL, Carrier::VERIZON, Carrier::USCELLULAR].include?(@carrier.id)
      @status = "red"
    else
      @status = "green"
    end
  end
  
  def layout
    'phone_finder' unless request.xhr?
  end
  
  def set_carrier
    @carrier = PhonesDatabase::Carrier.find(params[:carrier_id])
  end
  
  def set_manufacturer
    @manufacturer = PhonesDatabase::Manufacturer.find(params[:manufacturer_id]) if params[:manufacturer_id]
  end
  
  def set_phone_and_compatibilities
    result = PhonesDatabase::Finder.search(:phone_id => params[:id], :carrier => @carrier.id, :app => Application::SCHLAGE)
    @phone = result.phones[0]
    @manufacturer = PhonesDatabase::Manufacturer.find(@phone.manufacturer_id)
    begin
      @compatibilities = result.compatibilities
    rescue NoMethodError
      @compatibilities = []
    end
  end  
end
