class PhonesController < ApplicationController
  include SMSFu
  
  def download
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
end
