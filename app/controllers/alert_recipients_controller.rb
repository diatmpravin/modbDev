class AlertRecipientsController < ApplicationController
  def new
    @alert_recipient = current_account.alert_recipients.new
  end
  
  def create
    @alert_recipient = current_account.alert_recipients.build(params[:alert_recipient])
    
    if @alert_recipient.save
      render :json => {
        :status => 'success',
        :id => @alert_recipient.id,
        :display_string => @alert_recipient.display_string
      }
    else
      render :json => {
        :status => 'failure',
        :error => @alert_recipient.errors.map {|obj, err| "#{obj.humanize} #{err}"}
      }
    end
  end
end