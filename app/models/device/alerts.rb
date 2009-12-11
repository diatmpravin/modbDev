class Device < ActiveRecord::Base

  def alert_recipient_ids=(list)
    self.alert_recipients = account.alert_recipients.find(
      list.reject {|a| a.blank?}
    )
  end
  
end
