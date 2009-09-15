class PhonesController < ApplicationController
  include SMSFu
  
  before_filter :set_activation_code, :only => :activate
  before_filter :set_devices, :except => [:show, :activate, :destroy]
  before_filter :set_phone, :only => [:show, :edit, :update, :destroy]
  
  layout except_ajax('phones')
  
  def index
    @phones = current_account.phones
    @carriers = PhonesDatabase::Carrier.find(:all)
  end
  
  def download
    # Blargh! In-controller validation??!?
    # WHO DID THIS??????
    if params[:phone_number].match(/\d{10}/)
      deliver_sms(
        params[:phone_number],
        params[:phone_carrier],
        "Click a link #{phone_software_path}"
      )
      
      render :json => {:status => 'success'}
    else
      render :json => {:status => 'failure', :error => 'Enter your ten-digit cell phone number.'}
    end
  end
  
  def activate
    phone = Phone.find_by_activation_code(@activation_code)
    
    if !phone
      render :json => {
        :status => 'failure',
        :error => 'Unable to activate - please check your activation code.'
      }
    elsif !phone.activate(current_account)
      render :json => {
        :status => 'failure',
        :error => phone.errors.full_messages[0] ||
          'Your phone has already been activated. Select "OK" from the application menu on your phone.'
      }
    else
      render :json => {:status => 'success'}
    end
  end
  
  def show
  end
  
  def edit
  end
  
  def update
    params[:phone][:device_ids] ||= []
    
    if @phone.update_attributes(params[:phone])
      render :json => {:status => 'success'}
    else
      render :json => {
        :status => 'failure',
        :html => render_to_string(:action => 'edit')
      }
    end
  end
  
  def destroy
    @phone.update_attribute(:account, nil)
    render :json => {:status => 'success'}
  end
  
  protected
  def set_phone
    @phone = current_account.phones.find(params[:id])
  end
  
  def set_devices
    @devices = current_account.devices
  end
  
  def set_activation_code
    @activation_code = params[:activation_code]
  end
end
