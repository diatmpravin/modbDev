class AlertRecipientsController < ApplicationController
  def new
    @alert_recipient = current_account.alert_recipients.new
  end
  
  def create
    # If a matching (similar) record already exists, we will simply return it.
    @alert_recipient = current_account.alert_recipients.matching(params[:alert_recipient]).first
    
    if !@alert_recipient
      @alert_recipient = current_account.alert_recipients.new
    end
    
    if @alert_recipient.update_attributes(params[:alert_recipient])
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